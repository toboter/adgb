class ArtefactSerializer < ActiveModel::Serializer
  attributes :id, :bab_rel, :grabung, :bab, :bab_ind, :b_join, :b_korr, :mus_sig, :mus_nr, :mus_ind, :m_join, :m_korr, :kod, :grab, :text, :sig, :diss, :mus_id, :standort_alt, :standort, :mas1, :mas2, :mas3, :f_obj, :abklatsch, :abguss, :fo_tell, :fo1, :fo2, :fo3, :fo4, :fo_text, :UTMx, :UTMxx, :UTMy, :UTMyy, :inhalt, :period, :arkiv, :text_in_archiv, :jahr, :datum, :zeil2, :zeil1
end
