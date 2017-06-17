class Artefact < ApplicationRecord
  include SearchCop
  require 'roo'

  validates :bab_rel, presence: true

  has_many :accessibilities, as: :accessable, dependent: :destroy
  has_many :accessors, through: :accessibilities

  accepts_nested_attributes_for :accessibilities, reject_if: :all_blank, allow_destroy: true
  has_many :references, class_name: "ArtefactReference", foreign_key: "b_bab_rel", primary_key: :bab_rel
  accepts_nested_attributes_for :references, reject_if: :all_blank, allow_destroy: true
  has_many :illustrations, class_name: "ArtefactPhoto", foreign_key: "p_bab_rel", primary_key: :bab_rel
  has_many :photos, through: :illustrations
  accepts_nested_attributes_for :illustrations, reject_if: :all_blank, allow_destroy: true
  has_many :people, class_name: "ArtefactPerson", foreign_key: "n_bab_rel", primary_key: :bab_rel
  accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true
  belongs_to :creator, class_name: 'User'


 
  def self.visible_for(user)
    if user
      left_outer_joins(:accessibilities).where(accessibilities: {id: nil}).or(left_outer_joins(:accessibilities).where(accessibilities: {accessor_id: user.id}))
    else
      left_outer_joins(:accessibilities).where(accessibilities: {id: nil})
    end
  end

  def accessible_through?(user)
    user.in?(self.accessors) || self.accessors.empty?
  end
  
  # virtual attributes

  def self.col_attr
    attribute_names.map {|n| n unless ['id', 'created_at', 'updated_at'].include?(n) }.compact
  end  

  def bab_name
    grabung && bab ? "#{grabung} #{bab}#{bab_ind}" : nil
  end
  
  def mus_name
    mus_sig ? "#{mus_sig} #{mus_nr}#{mus_ind}" : nil
  end
  
  def full_entry
    "#{bab_name} #{mus_name}"
  end
  
  def utm?
    utmx && utmy
  end
  
  def to_lat_lon(zone)
    # Olof bemängelt eine Verschiebung der von ihm verwendeten UTM WGS84 Koordinaten in maps um E 27 und N 7
    # GeoUTM bietet verschiedene ellipsoide, das standard WGS84 führt zu dem besagten Verschiebungsfehler
    # neuer Versuch mit 'International' hier sind die angezeigten Koordinaten viel südlicher.
    # Laut Olof ergibt sich daraus ein noch viel größerer Fehler. Daher wieder wgs84. 
    # Nun aber mit 27m Abzug auf x und 7m auf der y Achse.
    GeoUtm::UTM.new(zone, utmx-27, utmy-7, "WGS-84").to_lat_lon if utm? && zone
  end
  
  #scopes
  
  filterrific(
    default_filter_params: { sorted_by: 'bab_desc' },
    available_filters: col_attr.map{|a| ("with_#{a}_like").to_sym}
      .concat([
        :sorted_by, 
        :search, 
        :with_photo_like, 
        :with_person_like,
        :with_bib_like
      ])
  )
  
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^bab_/
      order("LOWER(artefacts.bab_rel) #{ direction }")
    when /^mus_/
      order("LOWER(artefacts.mus_sig) #{ direction }, artefacts.mus_nr #{ direction }, artefacts.mus_ind #{ direction }, LOWER(artefacts.bab_rel) #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
  
  col_attr.map do |a|
    scope ("with_#{a}_like").to_sym, lambda { |x|
      where("LOWER(CAST(artefacts.#{a} AS TEXT)) LIKE ?", "%#{x.to_s.downcase}%")
    }
  end 
  
  scope :with_photo_like, lambda { |x|
    joins(:photos).where("LOWER(CAST(photos.ph_nr AS TEXT)) LIKE ?", "#{x.to_s.downcase}%")
   }
   
  scope :with_person_like, lambda { |x|
    joins(:people).where("LOWER(artefact_people.person) LIKE ?", "%#{x.to_s.downcase}%")
   }

  scope :with_bib_like, lambda { |x|
    joins(:references).where("CONCAT(LOWER(artefact_references.ver), LOWER(artefact_references.publ), LOWER(artefact_references.jahr)) LIKE ?", "%#{x.to_s.downcase}%")
   }
     
  def self.options_for_sorted_by
    [
      ['Excavation asc', 'bab_asc'],
      ['Excavation desc', 'bab_desc'],
      ['Museum asc', 'mus_asc'],
      ['Museum desc', 'mus_desc']
    ]
  end

  search_scope :search do
    attributes :bab_rel, :b_join, :b_korr, :mus_sig, :arkiv, :text_in_archiv,
               :mus_nr, :mus_ind, :m_join, :m_korr, :kod, :grab, :text, :sig, 
               :diss, :mus_id, :f_obj, :abklatsch, :abguss, :fo_tell, 
               :fo_text, :inhalt, :period, :jahr, :datum, :zeil2, :zeil1, :gr_datum, :gr_jahr,
               :fo1, :fo2, :fo3, :fo4, :mas1, :mas2, :mas3, :standort_alt, :standort, :utmx, :utmxx, :utmy, :utmyy
    attributes :excavation => "grabung"
    attributes :excavation_number => "bab"
    attributes :excavation_number_index => "bab_ind"
    attributes :person => ["people.person", "people.titel"]
    attributes :photo => "photos.ph_rel"
    attributes :illustration => ["illustrations.p_rel", "illustrations.position"]
    attributes :reference => ["references.ver", "references.publ"]

  end
 
  
  # import/export
  
  def self.import(file, creator_id)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    @user = User.find(creator_id)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      artefact = find_by_bab_rel(row["bab_rel"]) || new
      artefact.attributes = row.to_hash.slice(*Artefact.col_attr)
      
      artefact.creator = @user
      artefact.accessors << @user unless artefact.accessors.include?(@user)

      #for id in project_ids do
      #  artefact.accessibilities.where(project_id: id.to_i).first_or_create
      #end
      #raise artefact.accessibilities.inspect
      artefact.save!
    end
  end
  
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path)
    when ".ods" then Roo::OpenOffice.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end


end
