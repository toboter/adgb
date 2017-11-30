class SourceSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attribute :id
  attributes :type, :subtype
  attributes :identifier_stable, :identifier_temp, :type, :type_data, :remarks
  belongs_to :parent, serializer: SourceSerializer
  attributes :links
  attribute :full_entry

  def type
    'DocumentationObject'
  end

  def subtype
    object.type
  end

  def links
    {
      self: api_source_url(object, host: Rails.application.secrets.host),
      human: source_url(object, host: Rails.application.secrets.host)
    }
  end

  def full_entry
    'undefined'
  end
end
