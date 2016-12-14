class Artefact < ApplicationRecord
  include SearchCop
  require 'roo'


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

  def bab_name
    "#{grabung} #{bab}#{bab_ind}"
  end
  
  def mus_name
    "#{mus_sig} #{mus_nr}#{mus_ind}"
  end
  
  def full_entry
    "#{bab_name}; #{mus_name}"
  end
  
  
  #scopes
  
  filterrific(
    default_filter_params: { sorted_by: 'bab_desc' },
    available_filters: col_attr.map{|a| ("with_#{a}_like").to_sym}.concat([:sorted_by, :search])
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
      where("LOWER(CAST(artefacts.#{a} AS TEXT)) LIKE ?", "#{x.to_s.downcase}%")
    }
  end 
  
  def self.options_for_sorted_by
    [
      ['Excavation asc', 'bab_asc'],
      ['Excavation desc', 'bab_desc'],
      ['Museum asc', 'mus_asc'],
      ['Museum desc', 'mus_desc']
    ]
  end

  search_scope :search do
     attributes :bab_rel, :grabung, :bab, :bab_ind, :b_join, :b_korr, :mus_sig, 
               :mus_nr, :mus_ind, :m_join, :m_korr, :kod, :grab, :text, :sig, 
               :diss, :mus_id, :standort_alt, :standort, :mas1, :mas2, :mas3, 
               :f_obj, :abklatsch, :abguss, :fo_tell, :fo1, :fo2, :fo3, :fo4, 
               :fo_text, :utmx, :utmxx, :utmy, :utmyy, :inhalt, :period, 
               :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1, :gr_datum, :gr_jahr
    attributes :person => ["people.person", "people.titel"]
    attributes :photo => "photos.ph_rel"
    attributes :illustration => ["illustrations.p_rel", "illustrations.position"]
    attributes :reference => ["references.ver", "references.publ"]
  end
 
  
  # import/export
  
  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      artefact = find_by_bab_rel(row["bab_rel"]) || new
      artefact.attributes = row.to_hash.slice(*Artefact.col_attr)
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
