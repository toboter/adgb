class ArtefactSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type 'ExcavatedObject'
  
  attributes :id, :bab_rel, :updated_at, :published?
  attribute :creator do 
    {
      id: object.record_creator.try(:id),
      name: object.record_creator.try(:name),
      url: 'babili profile url'
    }
  end 
  attributes :full_entry, :grabung, :bab, :bab_ind, :b_join, :b_korr 
  attributes :mus_sig, :mus_nr, :mus_ind, :m_join, :m_korr
  attributes :mas1, :mas2, :mas3, :kod, :grab, :text, :sig, :f_obj, :abklatsch, :zeichnung
  attributes :fo_tell, :fo1, :fo2, :fo3, :fo4, :fo_text, :gr_datum, :gr_jahr
  attributes :inhalt, :period, :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1
  attributes :standort_alt, :standort, :diss, :mus_id
  has_many :sources
  has_many :references
  has_many :people

  attribute :location do
    {
      utmx: object.utmx,
      utmxx: object.utmxx,
      utmy: object.utmy,
      utmyy: object.utmyy,
      lat: object.latitude,
      lon: object.longitude
    }
  end

  attribute :links do
    {
      self: api_artefact_url(object.id),
      html_url: artefact_url(object)
    }
  end

  attribute(:accessor_uids) { object.record_accessors.map(&:uid)}

end