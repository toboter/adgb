class PhotoImport < ApplicationRecord
  extend FriendlyId
  require 'roo'
  include Enki

  friendly_id :ph_rel, use: :slugged
  
  has_many :references, class_name: "ArtefactReference", foreign_key: "ph_rel", primary_key: :ph_rel
  has_many :occurences, class_name: "ArtefactPhoto", foreign_key: "p_rel", primary_key: :ph_rel
  accepts_nested_attributes_for :occurences, reject_if: :all_blank, allow_destroy: true
  has_many :artefacts, through: :occurences

  def name
    "#{ph} #{ph_nr}#{ph_add}"
  end

  def self.col_attr
    %w(ph_rel ph ph_nr ph_add ph_datum ph_text)
  end

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
  
  col_attr.map do |a|
    scope ("with_#{a}_like").to_sym, lambda { |x|
      where("LOWER(CAST(photo_imports.#{a} AS TEXT)) LIKE ?", "%#{x.to_s.downcase}%")
    }
  end


  def self.import(file)
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1).map{|h| h.underscore }
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      photo = find_by_ph_rel(row["ph_rel"]) || new
      photo.attributes = row.to_hash.slice(*PhotoImport.col_attr)
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
