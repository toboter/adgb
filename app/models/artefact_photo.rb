# ArtefactSource

class ArtefactPhoto < ApplicationRecord
  require 'roo'

  belongs_to :artefact, foreign_key: "p_bab_rel", primary_key: 'bab_rel'
  belongs_to :source, optional: true

  def name
    "#{ph} #{ph_nr}#{ph_add}"
  end

  def self.col_attr
    %w(p_bab_rel ph ph_nr ph_add position p_rel source_slug)
  end

  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      a_photo = new # verweis muss neu gesetzt werden -> source_id
      a_photo.attributes = row.to_hash.slice(*ArtefactPhoto.col_attr)
      a_photo.save!
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
