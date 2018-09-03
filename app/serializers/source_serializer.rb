class SourceSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type 'DocumentationObject'

  attributes :id, :name, :call_number, :published?
  attribute :creator do 
    {
      id: object.record_creator.try(:id),
      name: object.record_creator.try(:name),
      url: 'babili profile url'
    }
  end 

  attributes :links
  attribute :full_entry

  def subtype
    object.type
  end

  def links
    {
      self: api_source_url(object),
      html_url: source_url(object),
      parent_url: object.child? ? api_source_url(object.parent) : nil
    }
  end

  attribute(:accessor_uids) { object.record_accessors.map(&:uid)}

  def full_entry
    'undefined'
  end
end
