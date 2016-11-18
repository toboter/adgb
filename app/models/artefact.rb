class Artefact < ApplicationRecord
  include SearchCop
  require 'roo'
  
  has_many :references, class_name: "ArtefactReference", dependent: :destroy, foreign_key: "b_bab_rel", primary_key: :bab_rel
  accepts_nested_attributes_for :references, reject_if: :all_blank, allow_destroy: true
  has_many :illustrations, class_name: "ArtefactPhoto", dependent: :destroy, foreign_key: "p_bab_rel", primary_key: :bab_rel
  has_many :photos, through: :illustrations
  accepts_nested_attributes_for :illustrations, reject_if: :all_blank, allow_destroy: true
  has_many :people, class_name: "ArtefactPerson", dependent: :destroy, foreign_key: "n_bab_rel", primary_key: :bab_rel
  accepts_nested_attributes_for :people, reject_if: :all_blank, allow_destroy: true
  
  validates :bab_rel, presence: true

  def bab_name
    "#{grabung} #{bab}#{bab_ind}"
  end
  
  def mus_name
    "#{mus_sig} #{mus_nr}#{mus_ind}"
  end
  
  def full_entry
    "#{bab_name}; #{mus_name}"
  end

  def self.col_attr
    %w(bab_rel grabung bab bab_ind b_join b_korr mus_sig mus_nr mus_ind m_join m_korr 
      kod grab text sig diss mus_id standort_alt standort mas1 mas2 mas3 f_obj 
      abklatsch abguss fo_tell fo1 fo2 fo3 fo4 fo_text UTMx UTMxx UTMy UTMyy 
      inhalt period arkiv text_in_archiv jahr datum zeil2 zeil1 gr_datum gr_jahr)
  end

  search_scope :search do
     attributes :bab_rel, :grabung, :bab, :bab_ind, :b_join, :b_korr, :mus_sig, 
               :mus_nr, :mus_ind, :m_join, :m_korr, :kod, :grab, :text, :sig, 
               :diss, :mus_id, :standort_alt, :standort, :mas1, :mas2, :mas3, 
               :f_obj, :abklatsch, :abguss, :fo_tell, :fo1, :fo2, :fo3, :fo4, 
               :fo_text, :UTMx, :UTMxx, :UTMy, :UTMyy, :inhalt, :period, 
               :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1, :gr_datum, :gr_jahr
    attributes :person => ["people.person", "people.titel"]
    attributes :photo => "photos.ph_rel"
    attributes :illustration => ["illustrations.p_rel", "illustrations.position"]
    attributes :reference => ["references.ver", "references.publ"]
  end
  
  
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
