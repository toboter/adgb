class ArtefactSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type 'ExcavatedObject'

  attribute :bab_rel, key: :id
  attribute :identification do
    {
      excavationNumber: {
        excavationProjectData: object.grabung,
        number: object.bab,
        numberIndex: number_index(object.bab_ind),
        literal: object.bab_name.try(:squish)
      },
      collectionNumber: {
        collectionData: object.mus_sig,
        number: object.mus_nr,
        numberIndex: number_index(object.mus_ind),
        literal: object.mus_name.try(:squish)
      },
      others: [
        label_value_hash('MusId', object.mus_id),
        label_value_hash('DissovId', object.diss)
      ].compact,
      comment: {
        de: '-'
      },
      joins: {
        # Enspricht nicht dem Schema
        b_join: object.b_join,
        b_korr: object.b_korr,
        m_join: object.m_join,
        m_korr: object.m_korr
      }
    }
  end

  attribute :excavationUnit do
    # Enspricht nicht dem Schema
    {
      tell: object.fo_tell, 
      fo1: object.fo1, 
      fo2: object.fo2, 
      fo3: object.fo3, 
      fo4: object.fo4, 
      comment: {
        de: object.fo_text
      }, 
      excavated: "#{object.gr_datum}#{object.gr_jahr}",
      geometry: {
        type: "Point",
        coordinates: [
          object.latitude, object.longitude
        ]
      },
      variation: {
        east: object.utmxx,
        north: object.utmyy
      }
    }
  end

  attribute :title do 
    {
      de: object.full_entry.try(:squish)
    }
  end

  attribute :description do
    [
      {
        de: object.f_obj,
        author: {
          name: object.record_creator.try(:name)
        },
        authored: object.created_at
      }
    ]
  end

  attribute :measurements do
    [
      measurement_hash('width', object.mas1, 'cm'),
      measurement_hash('height', object.mas2, 'cm'),
      measurement_hash('depth', object.mas3, 'cm')
    ].compact
  end

  attribute :locations do
    [
      location_hash(object.standort, 'current'),
      location_hash(object.standort_alt, 'historic-date')
  ].compact
  end

  attribute :tags do
    object.tag_list
  end
  attributes :kod, :grab, :text, :sig, :period

  attribute :citationItems do
    object.references.map { |r|
      {
        citationData: r.literature_item.try(:biblio_data).presence || r.literature_item.try(:title),
        locator: r.locator
      }
    }
  end

  attribute :archivalResources do
    object.illustrations.map{ |i|
      {
        archivalResourceData: i.source,
        locator: i.position,
        property: 'isPhotographedIn'
      }
    }
  end
  attributes :abklatsch, :zeichnung

  attribute :options do
    {
      content: object.inhalt, 
      archive: object.arkiv, 
      archiveTextNumber: object.text_in_archiv, 
      dating: {
        year: object.jahr, 
        date: object.datum
      },
      zeil2: object.zeil2, 
      zeil1: object.zeil1,
      namedPersons: object.people
    }
  end

  attributes :updated_at, :published?

  attribute :links do
    {
      self: api_artefact_url(object.id),
      html_url: artefact_url(object)
    }
  end

  def number_index(ind)
    ind.present? ? {value: ind} : nil
  end

  def label_value_hash(label, value)
    {
      label: label,
      value: value
    } if value.present?
  end

  def measurement_hash(type, value, unit)
    {
      type: type,
      value: value,
      unit: unit
    } if value.present?
  end

  def location_hash(raw, deposited)
    {
      raw: raw,
      deposited: deposited
    } if raw.present?
  end

  # attribute(:accessor_uids) { object.record_accessors.map(&:uid)}

end