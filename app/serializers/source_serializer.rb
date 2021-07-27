class SourceSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers
  type 'ArchivalResource'

  attribute :slug, key: :id
  attribute :containedIn do
    object.child? ? SourceInfoSerializer.new(object.parent) : ArchiveSerializer.new(object.archive)
  end
  attribute :serialNumber do
    object.sheet.presence || object.call_number.sub(object.collection, '').gsub(',', '').squish!
  end
  attribute :callNumber do
    {
      value: object.name,
      temporary: object.temp_call_number.present? && object.temp_call_number != object.call_number
    }
  end

  attribute :collectionData do
    {
      abbr: object.collection
    }
  end

  attribute :numberOfPieces do
    object.children.size
  end

  attribute :contains do
    object.children.map{ |c|
      {
        id: c.slug,
        callNumber: c.name
      }
    }
  end

  attribute :title do
    {de: object.title}
  end
  attribute :labeling, key: :label
  attribute :provenance
  attribute :summary do
    {
      de: object.description
    }
  end
  attribute :comment do
    {
      de: object.remarks
    }
  end

  attribute :measurements do
    [
      {raw: object.measurements}
    ]
  end

  attribute :locations do
    [
      location_hash(object.location_current, {dateParts: [2012]}),
      location_hash(object.location_history, {dateParts: [1917]})
  ].compact
  end

  attribute :tags do
    object.tag_list
  end

  attribute :accessibility do
    {
      condition: object.condition,
      restrictions: object.access_restrictions
    }
  end

  attribute :runtime do
    {
      raw: object.period
    }
  end

  attribute :people do
    [
      {
        role: 'Author',
        name: object.author
      }
    ]
  end

  attribute :citationItems do
    object.literature_item_sources.map { |r|
      {
        citationData: r.literature_item.try(:biblio_data).presence || r.literature_item.try(:title),
        locator: r.locator
      }
    }
  end

  attribute :excavatedObjects do
    object.occurences.map { |o|
      {
        excavatedObjectData: (o.try(:artefact) ? ArtefactInfoSerializer.new(o.artefact) : o.try(:p_bab_rel)),
        locator: o.position,
        property: 'isPhotographOf'
      }
    }
  end

  attribute :excavationUnits do
    []
  end

  attribute(:license) {'None'}

  attribute :copyrights do
    []
  end

  attribute :attachments do
    object.attachments.map do |a|
      {
        id: a.file_id,
        url: a.file_url
      }
    end
  end

  attribute :options do
    {
      relevance: object.relevance.map{|r| Source::REL_TYPES.select{|k,v| k == r.to_i }.map(&:last).join(', ') },
      relevanceComment: object.relevance_comment,
      digitalizationRemarks: object.digitize_remarks.map{|r| Source::DIGI_TYPES.select{|k,v| k == r.to_i }.map(&:last).join(', ') }
    }
  end

  attributes :updated_at, :published?

  attribute :contributors do
    User.find(object.versions.map(&:whodunnit).uniq).map { |u|
      {
        name: u.name
      }
    } if object.versions.any?
  end

  attribute :links do
    {
      self: api_source_url(object.id),
      html: source_url(object)
    }
  end

  attribute(:full_entry) {object.call_number}

  # ---

  def location_hash(raw, deposited)
    {
      raw: raw,
      deposited: deposited
    } if raw.present?
  end
end
