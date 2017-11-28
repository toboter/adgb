# Archiv

class Archive < Source
  jsonb_accessor :type_data,
    title: :string,
    holder: :string,
    contact: :text    


  def self.subtypes
    %w(Collection Folder Letter Contract Photo)
  end

  def self.jsonb_attributes
    # self.attribute_names
    jsonb_store_key_mapping_for_type_data.map{|j| j[0].to_sym}
  end

  def icon
    'institution'
  end

end