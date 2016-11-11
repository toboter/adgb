class ArtefactPerson < ApplicationRecord
  require 'roo'
  
  belongs_to :artefact, foreign_key: "bab_rel", primary_key: 'b_bab_rel'

  def self.col_attr
    %w(n_bab_rel person titel)
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      a_person = new
      a_person.attributes = row.to_hash.slice(*ArtefactPerson.col_attr)
      a_person.save!
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
