class ArtefactReference < ApplicationRecord
  require 'roo'
  
  belongs_to :artefact, foreign_key: "b_bab_rel", primary_key: 'bab_rel'

  def title
    "#{ver} [#{jahr}] #{publ}#{seite ? ': '+seite : ''}"
  end

  def self.col_attr
    %w(b_bab_rel ver publ jahr seite ph_rel)
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      a_reference = new
      a_reference.attributes = row.to_hash.slice(*ArtefactReference.col_attr)
      a_reference.save!
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
