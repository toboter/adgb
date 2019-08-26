# t.integer   :archive_id
# t.string    :collection
# t.string    :call_number
# t.string    :temp_call_number
# t.integer   :parent_id
# t.string    :sheet
# t.string    :type
# t.string    :genuineness (Original/Kopie)
# t.string    :material
# t.string    :measurements
# t.string    :title
# t.string    :labeling
# t.string    :provenance
# t.string    :period
# t.string    :author
# t.string    :size
# t.string    :contains
# t.string    :part_of
# t.string    :description
# t.string    :remarks
# t.string    :condition
# t.string    :access_restrictions  (Sperrvermerk)
# t.string    :loss_remarks
# t.string    :location_current
# t.string    :location_history
# t.string    :state
# t.text      :history
# t.string    :relevance
# t.string    :relevance_comment
# t.string    :digitize_remarks
# t.string    :keywords
# t.string    :links

# TODO
# import bauen
# get file_types from babylon-online

class Source < ApplicationRecord
  self.inheritance_column = :_type_disabled
  searchkick
  has_paper_trail ignore: [:slug, :updated_at], 
    meta: {
      version_name: :name, 
      changed_characters_length: :changed_characters,
      total_characters_length: :total_characters
    }
  include Filterable
  extend FriendlyId
  include Visibility
  acts_as_taggable

  has_closure_tree
  
  belongs_to :archive, counter_cache: true
  has_many :occurences, class_name: "ArtefactPhoto", foreign_key: :source_id, dependent: :destroy
  has_many :artefacts, through: :occurences
  has_many :attachments, dependent: :destroy
  has_many :literature_item_sources, dependent: :destroy
  has_many :literature_items, through: :literature_item_sources
  has_many :publications, class_name: 'ArtefactReference', foreign_key: :source_id
  accepts_nested_attributes_for :literature_item_sources, reject_if: :all_blank, allow_destroy: true

  def ph_rel
    "#{ph}#{ph_nr}#{ph_add}"
  end
  def references
    ArtefactReference.where(ph_rel: ph_rel)
  end

  after_commit :reindex_descendants
  #after_save :reslug_descendants, if: :identifier_stable_changed?
  friendly_id :name, use: :slugged

  validates :call_number, presence: { message: "can't be blank. At least use a temporary identifier, next field." }, unless: -> {temp_call_number.present?}

  attr_accessor :add_to_tag_list, :remove_from_tag_list

  accepts_nested_attributes_for :attachments, allow_destroy: true

  def changed_characters
    total = 0
    self.changes.each do |k,v|
      unless k.in?(['id', 'slug', 'locked', 'created_at', 'updated_at', 'parent_id'])
        ocl = v[0].to_s.length
        ncl = v[1].to_s.length
        changes = ocl > ncl ? ocl - ncl : ncl - ocl
        total = total + changes
      end
    end
    return total
  end

  def total_characters
    total = 0
    self.attributes.each do |k,v|
      total = total + v.to_s.length unless k.in?(['id', 'slug', 'locked', 'created_at', 'updated_at', 'parent_id'])
    end
    return total
  end

  # virtual attributes

  def archive_name=(value)
    self.archive = Archive.where(name: value).first_or_create
  end

  def archive_name
    archive.try(:name)
  end

  def tag_list
    tags.map{|t|  t.concept_data  }
  end

  def tag_list=(values)
    tags = []
    values.reject(&:empty?).each do |concept|
      concept = concept.is_a?(String) ? JSON.parse(concept) : concept
      id = concept['id'].split('/').last
      default_name = concept['prefLabel'].try('[]', 'de') || concept['prefLabel'].try('[]', 'en') || 'unknown language'
      default_url = concept['links']['html']
      tags << ActsAsTaggableOn::Tag.where(uuid: id).first_or_create(name: default_name, url: default_url, concept_data: concept)
    end
    self.tags = tags
  end

  def should_generate_new_friendly_id?
    (call_number_changed? || sheet_changed?) || super
  end

  # Naming

  def name_tree
    self_and_ancestors.auto_include(false).reverse.map{ |t| t.id }.join(' / ')
  end

  def name
    n = []
    n << call_number
    n << temp_call_number
    n << sheet
    return n.compact.flatten.reject(&:blank?).join(', ')
  end


  # Indexing and search

  def search_data
    attributes.except('relevance', 'digitize_remarks').merge(
      archive: archive.name,
      artefact: artefacts.map{|a| a.name },
      tag: tags.map{ |t| [t.try(:name), t.try(:concept_data).try(:to_json)] },
      publication: literature_item_sources.map{|r| [r.try(:literature_item).try(:full_citation), r.try(:literature_item).try(:title), r.locator]},
      relevance: relevance.map{|r| Source::REL_TYPES.select{|k,v| k == r.to_i }.map(&:last) },
      digital: digitize_remarks.map{|r| Source::DIGI_TYPES.select{|k,v| k == r.to_i }.map(&:last) }
    )
  end

  def reindex_descendants
    descendants.each do |subject|
      subject.reindex
    end
  end


  # Scopes

  scope :with_published_records, lambda { |flag|
    return nil  if 0 == flag # checkbox unchecked
    published
  }

  scope :with_unshared_records, lambda { |flag|
    return nil  if 0 == flag # checkbox unchecked
    inaccessible
  }

  scope :with_user_shared_to_like, lambda { |user_id|
    return nil if user_id.blank?
    user = User.find(user_id)
    accessible_by(user)
  }

  # Sorting

  def self.sorted_by(sort_option)
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^ident_name_/
      { slug: direction.to_sym }
    when /^created_at_/
      { created_at: direction.to_sym }
    when /^updated_at_/
      { updated_at: direction }
    when /^score_/
      { _score: direction }
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  end
   
  def self.options_for_sorted_by
    [
      ['Relevance asc', 'score_asc'],
      ['Relevance desc', 'score_desc'],
      ['Ident (a-z)', 'ident_name_asc'],
      ['Ident (z-a)', 'ident_name_desc'],
      ['Created (newest first)', 'created_at_desc'],
      ['Created (oldest first)', 'created_at_asc'],
      ['Updated asc', 'updated_at_asc'],
      ['Updated desc', 'updated_at_desc']
    ]
  end

  serialize :digitize_remarks, Array
  def digitize_remarks_list
    digitize_remarks
  end
  def digitize_remarks_list=(values)
    self.digitize_remarks = values.reject!(&:empty?)
  end
  DIGI_TYPES={
    1 => 'ja (Archivseitig vorhanden)',
    2 => 'ja (im Babylon-Projekt vorhanden)',
    3 => 'ja (VAM-seitig vorhanden)',
    4 => 'ja (vorhanden sein prüfen)',
    5 => 'nein (nicht zu digitalisieren)'
  }

  serialize :relevance, Array
  def relevance_list
    relevance
  end
  def relevance_list=(values)
    self.relevance = values.reject!(&:empty?)
  end
  REL_TYPES={
    0 => 'Babylon allgemein, durch Aufnahme Bearbeitung abgeschlossen',
    1 => 'Babylon-Projekt Allgemein, Dinge zu bearbeiten, Post It machen!',
    2 => 'Fallstudie CW/KS',
    3 => 'Sammlungs-studie MZ',
    4 => 'relevant für VAM-Kollegen, Assur, Uruk etc,.',
    5 => 'relevant für Rücklauf Archiv, z.B. zu inventarisieren oder sonst.'
  }
  

      # set User.current first
      def self.get_photos_from_photo_import(user_id)
        @user = User.find(user_id)
        PaperTrail.whodunnit = @user.id
        PhotoImport.auto_include(false).all.each do |import|
          import_name = "#{import.ph} #{import.ph_nr}#{import.ph_add}"
          source = Source.auto_include(false).where(call_number: import_name).first_or_initialize
          source.archive_name = 'Fotoarchiv'
          source.collection = import.ph
          source.call_number = import_name
          source.type = 'Photo'
          source.period = import.ph_datum
          source.description = import.ph_text
          source.slug = nil
          source.save!
          ArtefactPhoto.auto_include(false).where(p_rel: import.ph_rel).update_all(source_id: source.id)
        end
      end

      def self.reset_source_on_artefact_reference
        ArtefactReference.where.not(ph_rel: nil).each do |ref|
          ref.source = Source.where("REPLACE(call_number, ' ', '') LIKE ?", ref.ph_rel).first
          ref.save
        end

      end

end