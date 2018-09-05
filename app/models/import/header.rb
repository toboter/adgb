class Import::Header
  include AttrJson::Model
  attr_json :name, :string
  attr_json :mapping, :string

end