class ArchiveSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type 'Archive'

  attribute :name
  attribute(:type) {'Archive'}

end