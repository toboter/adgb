class ArtefactReference < ApplicationRecord
  require 'roo'

  alias_attribute :locator, :seite
  
  belongs_to :artefact, foreign_key: "b_bab_rel", primary_key: 'bab_rel', optional: true, touch: true
  belongs_to :literature_item, optional: true
  belongs_to :source, optional: true

  scope :without_artefact, -> { where(b_bab_rel: nil) }

  def title
    literature_item ? literature_item.title : "#{ver} [#{jahr}] #{publ}" + "#{seite ? ': '+seite : ''}"
  end

  def full_citation
    literature_item ? literature_item.full_citation.gsub(/\.$/, '') : title + "#{seite ? ': '+seite : ''}"
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

  def sync_to_literature
    self.literature_item = LiteratureItem.where(ver: ver, publ: publ, jahr: jahr).first_or_create
    return self.save!
  end

  def sync_between_literature_item_and_source
    if source.present?
      LiteratureItemSource.where(source_id: source_id, literature_item_id: literature_item_id).first_or_create(locator: locator)
      return true
    else
      return false
    end
  end
end
