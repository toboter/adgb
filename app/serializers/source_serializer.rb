class SourceSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type 'DocumentationObject'

  attributes :id, :subtype, :identifier_stable, :identifier_temp, :published?
  attribute :creator do 
    {
      id: object.record_creator.id,
      name: object.record_creator.name,
      url: 'babili profile url'
    }
  end 
  attributes :type_data, :remarks
  attributes :links
  attribute :full_entry

  def subtype
    object.type
  end

  def links
    {
      self: api_source_url(object),
      html_url: source_url(object),
      parent_url: api_source_url(object.parent)
    }
  end

  attribute(:accessor_uids) { object.record_accessors.map(&:uid)}

  def full_entry
    'undefined'
  end
end
