# Photo

class Photo < Source
  extend FriendlyId
  friendly_id :identifier_stable, use: [:slugged, :scoped], scope: :type

  has_many :occurences, class_name: "ArtefactPhoto", foreign_key: :source_id
  has_many :artefacts, through: :occurences

  jsonb_accessor :type_data,
    serie: :string,
    number: :string,
    addenda: :string,
    photo_at: :string,
    description: :text

  def self.subtypes
    %w()
  end

  def self.jsonb_attributes
    jsonb_store_key_mapping_for_type_data.map{|j| j[0].to_sym}
  end

  def search_data
    attributes.merge(artefacts: artefacts.map{|a| a})
  end

  def icon
    'image'
  end

    # set User.current first
    def self.get_photos_from_photo_import
      PhotoImport.all.each do |import|
        photo = Photo.all.type_data_where(serie: import.ph, number: import.ph_nr.to_s, addenda: import.ph_add).first_or_initialize
        photo.identifier_stable = "#{import.ph} #{import.ph_nr}#{import.ph_add}" 
        photo.serie = import.ph
        photo.number = import.ph_nr
        photo.addenda = import.ph_add
        photo.photo_at = import.ph_datum
        photo.description = import.ph_text
        photo.remarks = 'Cross import from xlsx'
        photo.slug = nil
        photo.save!
        ArtefactPhoto.where(p_rel: import.ph_rel).update_all(source_id: photo.id)
      end
    end
end