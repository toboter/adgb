class Artefact < ApplicationRecord
  # https://github.com/ankane/searchkick/issues/642
  # showing more than 10000 results on index
  searchkick
  has_paper_trail ignore: [:slug, :latitude, :longitude], 
    meta: {
      version_name: :name, 
      changed_characters_length: :changed_characters,
      total_characters_length: :total_characters
    }
  include Filterable
  extend FriendlyId
  require 'roo'
  include Nabu
  include Visibility

  friendly_id :bab_rel, use: :slugged
  before_save :set_code, :set_latitude, :set_longitude
  # after_commit :reindex_descendants


  def changed_characters
    total = 0
    self.changes.each do |k,v|
      unless k.in?(['id', 'slug', 'latitude', 'longitude', 'locked', 'created_at', 'updated_at'])
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
      total = total + v.to_s.length unless k.in?(['id', 'slug', 'latitude', 'longitude', 'locked', 'created_at', 'updated_at'])
    end
    return total
  end

  validates :bab_rel, presence: true

  has_many :references, class_name: "ArtefactReference", foreign_key: "b_bab_rel", primary_key: :bab_rel
  accepts_nested_attributes_for :references, reject_if: :all_blank, allow_destroy: true
  has_many :illustrations, class_name: "ArtefactPhoto", foreign_key: "p_bab_rel", primary_key: :bab_rel
  has_many :photos, through: :illustrations
  accepts_nested_attributes_for :illustrations, reject_if: :all_blank, allow_destroy: true
  has_many :people, class_name: "ArtefactPerson", foreign_key: "n_bab_rel", primary_key: :bab_rel
  accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true
  

  # virtual attributes

  def self.col_attr
    attribute_names.map {|n| n unless ['id', 'created_at', 'updated_at'].include?(n) }.compact
  end


  # Naming

  def name
    bab_name || mus_name
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

  col_attr.map do |a|
    scope ("with_#{a}_like").to_sym, lambda { |x|
      where("LOWER(CAST(artefacts.#{a} AS TEXT)) LIKE ?", "%#{x.to_s.downcase}%")
    }
  end 
  
  scope :with_photo_like, lambda { |x|
    joins(:photos).where("LOWER(CAST(photos.identifier_stable AS TEXT)) LIKE ?", "#{x.to_s.downcase}%")
   }
   
  scope :with_person_like, lambda { |x|
    joins(:people).where("LOWER(artefact_people.person) LIKE ?", "%#{x.to_s.downcase}%")
   }

  scope :with_bib_like, lambda { |x|
    joins(:references).where("CONCAT(LOWER(artefact_references.ver), LOWER(artefact_references.publ), LOWER(artefact_references.jahr)) LIKE ?", "%#{x.to_s.downcase}%")
   }


  def self.sorted_by(sort_option)
    direction = ((sort_option =~ /desc$/) ? 'desc' : 'asc').to_sym
    unless sort_option.nil?
      case sort_option.to_s
      when /^bab_/
        { grabung: direction, bab: direction }
      when /^mus_/
        { mus_sig: direction, mus_nr: direction, mus_ind: direction }
      when /^updated_at_/
        { updated_at: direction }
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
      end
    end
  end

  def self.options_for_sorted_by
    [
      ['Excavation asc', 'bab_asc'],
      ['Excavation desc', 'bab_desc'],
      ['Museum asc', 'mus_asc'],
      ['Museum desc', 'mus_desc'],
      ['Updated asc', 'updated_at_asc'],
      ['Updated desc', 'updated_at_desc']
    ]
  end



  # Indexing and search

  def search_data
    attributes.merge(
      references: references.map{|r| r},
      people: people.map{|p| p},
      photos: photos.map{|p| p},
      type: 'Artefakt'
    )
  end

  # def reindex_descendants
  #   descendants.each do |subject|
  #     subject.reindex
  #   end
  # end

  
  # KOD lookup

  KOD_MATERIAL = {
    "A" => "Asphalt",
    "B" => "Bestattung(sbeigabe)",
    "G" => "Glas",
    "H" => "Holz",
    "K" => "Knochen/Muschel",
    "M" => "Metall",
    "Q" => "Quarzkeramik",
    "S" => "Stein",
    "T" => "Ton",
    "W" => "Wandputz/Estrich",
    "X" => "Probe",
    "-" => "unbestimmt",
    "?" => "unbestimmt"
  }

  KOD_GRUPPE = {
    "A" => "Altar",
    "B" => "Bulle/Gefäßverschluss",
    "C" => "Glocke",
    "D" => "Brenndreieck",
    "E" => "Gewicht",
    "F" => "Figur/Fibel",
    "G" => "Gefäß",
    "J" => "Schmuck/Perle(n)",
    "K" => "Knopf/Knauf",
    "L" => "Lampe",
    "M" => "Münze",
    "O" => "Ring/Reif",
    "P" => "Platte",
    "R" => "Zylinder",
    "S" => "Siegel",
    "T" => "Tafel",
    "W" => "Wirtel",
    "Z" => "Ziegel",
    "-" => "unbestimmt",
    nil => "unbestimmt"
  }

  KOD_BEARBEITUNG = {
    "G" => "glasiert",
    "H" => "Dach/Hegemon",
    "R" => "reliefiert",
    nil => nil
  } 
 
  def kod_to_values
    if kod.present? 
      kod.split(' ')
        .map{ |key| [Artefact::KOD_MATERIAL[key[0]], Artefact::KOD_GRUPPE[key[1]], Artefact::KOD_BEARBEITUNG[key[2]]].compact }
        .join(', ')
    else
      'unbestimmt'
    end
  end

  def set_code
    self.code = kod_to_values
  end



  # GEO

  def set_latitude
    self.latitude = to_lat_lon('38S').lat if utm?
  end

  def set_longitude
    self.longitude = to_lat_lon('38S').lon if utm?
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



  # Import/export
  
  def self.import(file, creator_id)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    @user = User.find(creator_id)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      artefact = find_by_bab_rel(row["bab_rel"]) || new
      artefact.attributes = row.to_hash.slice(*Artefact.col_attr)
      
      # artefact.creator = @user
      # artefact.share_to(@user, @user, true) unless artefact.record_accessors.include?(@user.id)

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




  # nicht mehr aktuell seit 2017-12-06
  # KOD_MATERIAL = {
  #   "A" => "Asphalt", 
  #   "B" => "Bestattung(sbeigabe)",
  #   "G" => "Glas",
  #   "H" => "Holz",
  #   "K" => "Knochen/Muschel",
  #   "M" => "Metall",
  #   "Q" => "Quarzkeramik",
  #   "S" => "Stein",
  #   "T" => "Ton",
  #   "W" => "Wandputz/Estrich",
  #   "X" => "Probe",
  #   "Z" => "Ziegel",
  #   "-" => "unbestimmt",
  #   "?" => "unbestimmt",
  # }
  #  KOD_ART = {
  #   "A" => "Altar",
  #   "B" => "Bulle/Gefäßverschluss",
  #   "C" => "Glocke",
  #   "D" => "Brenndreieck",
  #   "E" => "Gewicht",
  #   "F" => "Figur/Figürliches",
  #   "G" => "Gefäß",
  #   "J" => "Schmuck/Perle(n)",
  #   "K" => "Knopf/Knauf",
  #   "L" => "Lampe",
  #   "M" => "Münze",
  #   "O" => "Ring/Reif",
  #   "P" => "Platte",
  #   "S" => "Siegel",
  #   "T" => "Tafel",
  #   "W" => "Wirtel",
  #   "Z" => "Zylinder",
  #   # "G" => "(glasiert)",
  #   "H" => "(Dach, hellenistisch)",
  #   "Q" => "(Kunststein)",
  #   "R" => "(reliefiert)",
  #   "?" => "unbestimmt",
  #   nil => "unbestimmt"
  # }