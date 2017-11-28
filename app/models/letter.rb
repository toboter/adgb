# Brief

class Letter < Source
  jsonb_accessor :type_data,
    sender: :string,
    recipient: :string,
    summary: :text,
    sent_at: :date

  def self.subtypes
    %w(Contract)
  end

  def self.jsonb_attributes
    jsonb_store_key_mapping_for_type_data.map{|j| j[0].to_sym}
  end

  def icon
    'file'
  end
end