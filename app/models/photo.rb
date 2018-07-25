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

  def ph_rel
    "#{serie}#{number}#{addenda}"
  end

  def references
    ArtefactReference.where(ph_rel: ph_rel)
  end

  def search_data
    attributes.merge(
      artefacts: artefacts.map{|a| [a, a.full_entry].join(' ') },
      ancestors: ancestors.map{|p| p},
      references: references.map{|r| r},
      full_id: self_and_ancestors.auto_include(false).reverse.map{ |t| t.name })
  end

  def icon
    'image'
  end

    # set User.current first
    def self.get_photos_from_photo_import(user_id)
      @user = User.find(user_id)
      PaperTrail.whodunnit = @user.id
      PhotoImport.auto_include(false).all.each do |import|
        photo = Photo.auto_include(false).all.type_data_where(serie: import.ph, number: import.ph_nr.to_s, addenda: import.ph_add).first_or_initialize
        photo.identifier_stable = "#{import.ph} #{import.ph_nr}#{import.ph_add}" 
        photo.serie = import.ph
        photo.number = import.ph_nr
        photo.addenda = import.ph_add
        photo.photo_at = import.ph_datum
        photo.description = import.ph_text
        photo.remarks = 'Cross import from xlsx'
        photo.slug = nil
        photo.save!
        ArtefactPhoto.auto_include(false).where(p_rel: import.ph_rel).update_all(source_id: photo.id)
      end
    end
end