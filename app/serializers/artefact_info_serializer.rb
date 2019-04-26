class ArtefactInfoSerializer < ActiveModel::Serializer
  attribute(:id) {object.slug}
  attribute :excavationNumber do 
    {
      excavationProjectData: object.grabung,
      number: object.bab,
      numberIndex: number_index(object.bab_ind),
      literal: object.bab_name.try(:squish)
    }
  end
  attribute :collectionNumber do 
    {
      collectionData: object.mus_sig,
      number: object.mus_nr,
      numberIndex: number_index(object.mus_ind),
      literal: object.mus_name.try(:squish)
    }
  end

  # ---

  def number_index(ind)
    ind.present? ? {value: ind} : nil
  end
end