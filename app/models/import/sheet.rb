module Import
  class Sheet < ApplicationRecord
    # t.integer  :event_id, index: true
    # t.string   :name
    # t.integer  :rows_count
    # t.integer  :headers_count
    # t.string   :model_mapping

    belongs_to :event, counter_cache: true
    has_many :headers, dependent: :destroy

    def load_import
      spreadsheet = event.open_spreadsheet
      sheet = spreadsheet.sheet(name)
      klass = model_mapping.classify.constantize
      
      items = []
      header = sheet.row(1).map{ |h| headers.find_by_name(h).attribute_mapping }
      (2..spreadsheet.last_row).map do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        item = klass.find_by_id(row["id"]) || klass.new
        item.attributes = row.to_hash.slice(*klass.col_attr)
        items << item
      end
      return items
    end

  end
end