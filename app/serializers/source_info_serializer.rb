class SourceInfoSerializer < ActiveModel::Serializer
  attribute :slug, key: :id
  attribute :containedIn do
    object.child? ? SourceInfoSerializer.new(object.parent) : (object.archive.present? ? ArchiveSerializer.new(object.archive) : nil)
  end
  attribute :serialNumber do
    object.sheet.presence || object.call_number.sub((object.collection.presence || ''), '').sub((object.archive.try(:name).presence || ''), '').gsub(',', '').squish!
  end
  attribute :callNumber do
    {
      value: object.name,
      temporary: object.temp_call_number.present? && object.temp_call_number != object.call_number
    }
  end
  attribute :collectionData do
    {
      abbr: object.collection
    }
  end
  attribute :name
end
