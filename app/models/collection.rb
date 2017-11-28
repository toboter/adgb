# Bestand

class Collection < Source
  jsonb_accessor :type_data,
    title: :string,
    description: :text

  def self.subtypes
    %w(Folder Letter Contract Photo)
  end

  def self.jsonb_attributes
    jsonb_store_key_mapping_for_type_data.map{|j| j[0].to_sym}
  end

  def icon
    'archive'
  end
end