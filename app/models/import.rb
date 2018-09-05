# t.file  has_file
# t.string  :name
# t.timestamps
# t.jsonb   :data

# class Import < ApplicationRecord
#   include AttrJson::Record
#   include AttrJson::Record::QueryScopes
# 
#   attr_json_config(default_container_attribute: :data)
#   attr_json :headers, Import::Header.to_type, array: true
# end