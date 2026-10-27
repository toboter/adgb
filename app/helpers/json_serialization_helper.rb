# Hash builders that preserve the AMS :json payload shape for artefacts/sources.
module JsonSerializationHelper
  include Rails.application.routes.url_helpers

  def default_url_options
    Rails.application.routes.default_url_options.presence ||
      { host: "www.example.com" }
  end

  def number_index(ind)
    ind.present? ? { value: ind } : nil
  end

  def label_value_hash(label, value)
    { label: label, value: value } if value.present?
  end

  def measurement_hash(type, value, unit)
    { type: type, value: value, unit: unit } if value.present?
  end

  def location_hash(raw, deposited)
    { raw: raw, deposited: deposited } if raw.present?
  end

  def archive_json(archive)
    return nil if archive.nil?

    {
      name: archive.name,
      type: "Archive"
    }
  end

  def source_info_json(source)
    return nil if source.nil?

    {
      id: source.slug,
      containedIn: source.child? ? source_info_json(source.parent) : archive_json(source.archive),
      serialNumber: source_serial_number(source),
      callNumber: {
        value: source.name,
        temporary: source.temp_call_number.present? && source.temp_call_number != source.call_number
      },
      collectionData: {
        abbr: source.collection
      },
      name: source.name
    }
  end

  def artefact_info_json(artefact)
    return nil if artefact.nil?

    {
      id: artefact.slug,
      excavationNumber: {
        excavationProjectData: artefact.grabung,
        number: artefact.bab,
        numberIndex: number_index(artefact.bab_ind),
        literal: artefact.bab_name.try(:squish),
        registered: {
          dateParts: artefact.gr_date_arr,
          literal: "#{artefact.gr_datum}#{artefact.gr_jahr}"
        }
      },
      collectionNumber: {
        collectionData: {
          abbr: artefact.mus_sig,
          holder: artefact.holder
        },
        number: artefact.mus_nr,
        numberIndex: number_index(artefact.mus_ind),
        literal: artefact.mus_name.try(:squish),
        registered: {}
      }
    }
  end

  def artefact_json(artefact)
    {
      id: artefact.slug,
      identification: {
        excavationNumber: {
          excavationProjectData: artefact.grabung,
          number: artefact.bab,
          numberIndex: number_index(artefact.bab_ind),
          literal: artefact.bab_name.try(:squish),
          registered: {
            dateParts: artefact.gr_date_arr,
            literal: "#{artefact.gr_datum}#{artefact.gr_jahr}"
          }
        },
        collectionNumber: {
          collectionData: {
            abbr: artefact.mus_sig,
            holder: artefact.holder
          },
          number: artefact.mus_nr,
          numberIndex: number_index(artefact.mus_ind),
          literal: artefact.mus_name.try(:squish),
          registered: {}
        },
        others: [
          label_value_hash("MusId", artefact.mus_id),
          label_value_hash("DissovId", artefact.diss)
        ].compact,
        joins: {
          b_join: artefact.b_join,
          b_korr: artefact.b_korr,
          m_join: artefact.m_join,
          m_korr: artefact.m_korr
        }
      },
      excavationUnit: {
        tell: artefact.fo_tell,
        fo1: artefact.fo1,
        fo2: artefact.fo2,
        fo3: artefact.fo3,
        fo4: artefact.fo4,
        comment: {
          de: artefact.fo_text
        },
        excavated: {},
        geometry: {
          type: "Point",
          coordinates: [
            artefact.latitude, artefact.longitude
          ]
        },
        variation: {
          east: artefact.utmxx,
          north: artefact.utmyy
        }
      },
      title: {
        de: artefact.full_entry.try(:squish)
      },
      description: [
        {
          de: artefact.f_obj,
          author: {
            name: artefact.record_creator.try(:name)
          },
          authored: artefact.created_at
        }
      ],
      measurements: [
        measurement_hash("width", artefact.mas1, "cm"),
        measurement_hash("height", artefact.mas2, "cm"),
        measurement_hash("depth", artefact.mas3, "cm")
      ].compact,
      locations: [],
      tags: artefact.tag_list,
      kod: artefact.kod,
      grab: artefact.grab,
      text: artefact.text,
      sig: artefact.sig,
      period: artefact.period,
      citationItems: artefact.references.map { |r|
        {
          citationData: r.literature_item.try(:biblio_data).presence || r.literature_item.try(:title),
          locator: r.locator
        }
      },
      archivalResources: artefact.illustrations.map { |i|
        {
          archivalResourceData: (i.try(:source) ? source_info_json(i.source) : i.name),
          locator: i.position,
          property: "isPhotographedIn"
        }
      },
      abklatsch: artefact.abklatsch,
      zeichnung: artefact.zeichnung,
      options: {
        content: artefact.inhalt,
        archive: artefact.arkiv,
        archiveTextNumber: artefact.text_in_archiv,
        dating: {
          year: artefact.jahr,
          date: artefact.datum
        },
        zeil2: artefact.zeil2,
        zeil1: artefact.zeil1,
        namedPersons: artefact.people
      },
      updated_at: artefact.updated_at,
      "published?": artefact.published?,
      contributors: artefact_contributors(artefact),
      links: {
        self: api_artefact_url(artefact.id),
        html: artefact_url(artefact)
      },
      full_entry: artefact.name
    }
  end

  def source_json(source)
    {
      id: source.slug,
      containedIn: source.child? ? source_info_json(source.parent) : archive_json(source.archive),
      serialNumber: source_serial_number(source),
      callNumber: {
        value: source.name,
        temporary: source.temp_call_number.present? && source.temp_call_number != source.call_number
      },
      collectionData: {
        abbr: source.collection
      },
      numberOfPieces: source.children.size,
      contains: source.children.map { |c|
        {
          id: c.slug,
          callNumber: c.name
        }
      },
      title: { de: source.title },
      label: source.labeling,
      provenance: source.provenance,
      summary: {
        de: source.description
      },
      comment: {
        de: source.remarks
      },
      measurements: [
        { raw: source.measurements }
      ],
      locations: [
        location_hash(source.location_current, { dateParts: [] }),
        location_hash(source.location_history, { dateParts: [] })
      ].compact,
      tags: source.tag_list,
      accessibility: {
        condition: source.condition,
        restrictions: source.access_restrictions
      },
      runtime: {
        raw: source.period
      },
      people: [
        {
          role: "Author",
          name: source.author
        }
      ],
      citationItems: source.literature_item_sources.map { |r|
        {
          citationData: r.literature_item.try(:biblio_data).presence || r.literature_item.try(:title),
          locator: r.locator
        }
      },
      excavatedObjects: source.occurences.map { |o|
        {
          excavatedObjectData: (o.try(:artefact) ? artefact_info_json(o.artefact) : o.try(:p_bab_rel)),
          locator: o.position,
          property: "isPhotographOf"
        }
      },
      excavationUnits: [],
      license: "None",
      copyrights: [],
      attachments: source.attachments.map { |a|
        {
          id: a.file_id,
          url: a.file_url
        }
      },
      options: {
        relevance: Array(source.relevance).map { |r| Source::REL_TYPES.select { |k, _v| k == r.to_i }.map(&:last).join(", ") },
        relevanceComment: source.relevance_comment,
        digitalizationRemarks: Array(source.digitize_remarks).map { |r| Source::DIGI_TYPES.select { |k, _v| k == r.to_i }.map(&:last).join(", ") }
      },
      updated_at: source.updated_at,
      "published?": source.published?,
      contributors: source_contributors(source),
      links: {
        self: api_source_url(source.id),
        html: source_url(source)
      },
      full_entry: source.call_number
    }
  end

  private

  def source_serial_number(source)
    source.sheet.presence ||
      source.call_number.to_s
            .sub((source.collection.presence || ""), "")
            .sub((source.archive.try(:name).presence || ""), "")
            .gsub(",", "")
            .squish!
  end

  def artefact_contributors(artefact)
    return nil unless artefact.versions.any?

    User.find(artefact.versions.map(&:whodunnit).uniq).map { |u| { name: u.name } }
  end

  def source_contributors(source)
    return nil unless source.versions.any?

    User.find(source.versions.map(&:whodunnit).uniq).map { |u| { name: u.name } }
  end
end
