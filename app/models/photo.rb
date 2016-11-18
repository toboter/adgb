class Photo < ApplicationRecord
  require 'roo'
  
  has_many :references, class_name: "ArtefactReference", foreign_key: "ph_rel", primary_key: :ph_rel
  has_many :occurences, class_name: "ArtefactPhoto", foreign_key: "p_rel", primary_key: :ph_rel
  has_many :artefacts, through: :occurences

  def name
    "#{ph} #{ph_nr}#{ph_add}"
  end

  def self.col_attr
    %w(ph_rel ph ph_nr ph_add ph_datum ph_text)
  end
  
  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      photo = find_by_ph_rel(row["ph_rel"]) || new
      photo.attributes = row.to_hash.slice(*Photo.col_attr)
      photo.save!
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
