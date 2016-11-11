class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :ph_rel, :ph, :ph_nr, :ph_add, :ph_datum, :ph_text
end
