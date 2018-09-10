module Import
  class Event < ApplicationRecord
    # t.string  :name
    # t.integer :creator_id
    # t.integer :sheets_count
    # t.timestamps

    has_one_attached :file, dependent: :purge
    belongs_to :creator, class_name: 'User'
    has_many :sheets, dependent: :destroy

    validates :name, :file, :creator_id, presence: true

    before_create :read_upload_data

    def read_upload_data
      spreadsheet = open_spreadsheet
      spreadsheet.sheets.each do |name|
        sheet = Sheet.new(name: name)
        sheet.rows_count = spreadsheet.sheet(name).last_row
        sheet.headers = spreadsheet.sheet(name).row(spreadsheet.sheet(name).header_line).compact.map{ |h| Header.new(name: h) }
        self.sheets << sheet
      end
    end

    def open_spreadsheet
      ext = file.filename.extension_with_delimiter
      case ext
      when ".csv" then Roo::Csv.new(tempfile)
      when ".ods" then Roo::OpenOffice.new(tempfile)
      when ".xlsx" then Roo::Excelx.new(tempfile)
      else raise "Unknown file type: #{ext}"
      end
    end

    def tempfile
      path = "#{Dir.tmpdir}/#{file.filename}"
      File.open(path, 'wb') do |tmpfile|
        tmpfile.write(file.download)
      end 
      return File.open(path)
    end
  end
end