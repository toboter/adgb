class Photo < ApplicationRecord
  extend FriendlyId
  include SearchCop
  require 'roo'
  include Enki

  friendly_id :ph_rel
  
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

  filterrific(
    default_filter_params: { sorted_by: 'photo_asc' },
    available_filters: col_attr.map{|a| ("with_#{a}_like").to_sym}
      .concat([
        :sorted_by, 
        :search
      ])
  )
  
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^photo_/
      order("LOWER(photos.ph) #{ direction }, photos.ph_nr #{ direction }, photos.ph_add #{ direction }")
    else
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
  
  col_attr.map do |a|
    scope ("with_#{a}_like").to_sym, lambda { |x|
      where("LOWER(CAST(photos.#{a} AS TEXT)) LIKE ?", "%#{x.to_s.downcase}%")
    }
  end 

     
  def self.options_for_sorted_by
    [
      ['Photo asc', 'photo_asc'],
      ['Photo desc', 'photo_desc']
    ]
  end

  search_scope :search do
    attributes :ph_rel, :ph, :ph_nr, :ph_add, :ph_datum, :ph_text
    attributes :artefacts => ["artefacts.bab_rel", "artefacts.grabung", "artefacts.bab", "artefacts.bab_ind"]
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
