class SourceInfoSerializer < ActiveModel::Serializer
  attribute :slug, key: :id
  attribute :containedIn do
    object.child? ? SourceSerializer.new(object.parent) : ArchiveSerializer.new(object.archive)
  end
  attribute :serialNumber do
    object.sheet.presence || object.call_number.sub(object.collection, '').sub(object.archive.try(:name), '').gsub(',', '').squish!
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
end