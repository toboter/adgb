class Source < ApplicationRecord
  searchkick
  include Filterable
  extend FriendlyId
  include Nabu
  include Enki
  has_closure_tree

  after_commit :reindex_descendants
  #after_save :reslug_descendants, if: :identifier_stable_changed?
  friendly_id :slug

  validates :type, presence: true
  validates :identifier_stable, presence: { message: "can't be blank. At least use a temporary identifier, next field." }, unless: -> {identifier_temp.present?}
  validates :identifier_stable, uniqueness: { scope: :type }



  # virtual attributes

  def self.types
    %w(Archive Collection Folder Letter Contract Photo)
  end

  def self.all_jsonb_attributes
    types.map{ |t| t.constantize.jsonb_attributes }.flatten.uniq
  end
  


  # Naming

  def name_tree
    self_and_ancestors.reverse.map{ |t| t.name }.join(' / ')
  end

  def name
    read_attribute(:identifier_stable).presence || ">#{identifier_temp}<"
  end

  # def slug_name
  #   ([parent.present? ? parent.self_and_ancestors.reverse.map{ |t| t.read_attribute(:identifier_stable).presence || t.friendly_id } : ''] + [identifier_stable]).join(' / ')
  # end


  # Indexing and search

  def search_data
    attributes.merge(ancestors: ancestors.map{|a| a})
  end

  def reindex_descendants
    descendants.each do |subject|
      subject.reindex
    end
  end


  
  # Scopes

  scope :with_published_records, lambda { |flag|
    return nil  if 0 == flag # checkbox unchecked
    published_records
  }

  scope :with_unshared_records, lambda { |flag|
    return nil  if 0 == flag # checkbox unchecked
    inaccessible_records
  }

  scope :with_user_shared_to_like, lambda { |user_id|
    return nil if user_id.blank?
    user = User.find(user_id)
    accessible_by_records(user)
  }

  scope :archives, -> { where(type: 'Archive') } 
  scope :collections, -> { where(type: 'Collection') } 
  scope :folders, -> { where(type: 'Folder') }
  scope :letters, -> { where(type: 'Letter') }
  scope :photos, -> { where(type: 'Photo') }
  


  # Sorting

  def self.sorted_by(sort_option)
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    unless sort_option.nil?
      case sort_option.to_s
      when /^ident_name_/
        { slug: direction.to_sym }
      when /^created_at_/
        { created_at: direction.to_sym }
      when /^updated_at_/
        { updated_at: direction }
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
      end
    end
  end
   
  def self.options_for_sorted_by
    [
      ['Ident (a-z)', 'ident_name_asc'],
      ['Ident (z-a)', 'ident_name_desc'],
      ['Created (newest first)', 'created_at_desc'],
      ['Created (oldest first)', 'created_at_asc'],
      ['Updated asc', 'updated_at_asc'],
      ['Updated desc', 'updated_at_desc']
    ]
  end



  # def should_generate_new_friendly_id?
  #   identifier_stable_changed? || super
  # end

  # def reslug_descendants #if identifier_stable_changed?
  #   descendants.each do |child|
  #     child.slug = nil
  #     child.save
  #   end
  # end

end