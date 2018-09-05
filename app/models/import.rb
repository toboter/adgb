# t.string  :name
# t.jsonb   :data
# t.integer :creator_id
# t.timestamps

class Import < ApplicationRecord
  include AttrJson::Record
  include AttrJson::Record::QueryScopes

  has_one_attached :file
  belongs_to :creator, class_name: 'User'

  attr_json_config(default_container_attribute: :data)
  attr_json :headers, Import::Header.to_type, array: true
end