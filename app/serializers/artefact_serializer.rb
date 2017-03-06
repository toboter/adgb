class ArtefactSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  
  attributes :type, :bab_rel
  attributes :full_entry
  attributes :grabung, :bab, :bab_ind, :b_join, :b_korr
  attributes :mus_sig, :mus_nr, :mus_ind, :m_join, :m_korr
  attributes :mas1, :mas2, :mas3
  attributes :kod, :grab, :text, :sig, :f_obj, :abklatsch, :abguss
  attributes :fo_tell, :fo1, :fo2, :fo3, :fo4, :fo_text, :utmx, :utmxx, :utmy, :utmyy
  attributes :inhalt, :period, :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1
  attributes :standort_alt, :standort, :diss, :mus_id
  attributes :links
  
  
  def type
    'Koldewey-Artefact'
  end

  def links
    {
      self: api_artefact_url(object, host: Rails.application.secrets.host),
      human: artefact_url(object, host: Rails.application.secrets.host)
    }
  end

end
