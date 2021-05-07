class ArtefactInfoSerializer < ActiveModel::Serializer
  attribute(:id) {object.slug}
  attribute :excavationNumber do
    {
      excavationProjectData: object.grabung,
      number: object.bab,
      numberIndex: number_index(object.bab_ind),
      literal: object.bab_name.try(:squish),
      registered: {
        dateParts: object.gr_date_arr,
        literal: "#{object.gr_datum}#{object.gr_jahr}"
      }
    }
  end
  attribute :collectionNumber do
    {
      collectionData: {
        abbr: object.mus_sig,
        holder: object.holder
      },
      number: object.mus_nr,
      numberIndex: number_index(object.mus_ind),
      literal: object.mus_name.try(:squish),
      registered: {
      }
    }
  end

  # ---

  def number_index(ind)
    ind.present? ? {value: ind} : nil
  end
end
