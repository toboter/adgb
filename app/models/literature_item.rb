class LiteratureItem < ApplicationRecord
  has_many :artefact_references
  has_many :artefacts, through: :artefact_references
  has_many :literature_item_sources
  has_many :sources, through: :literature_item_sources

  validates :ver, uniqueness: { scope: [:jahr, :publ] }
  validates :jahr, uniqueness: { scope: [:ver, :publ] }
  validates :publ, uniqueness: { scope: [:jahr, :ver] }

  after_commit :reindex_relations, on: [:update, :destroy]

  def biblio_data=(value)
    self[:biblio_data] = value.is_a?(String) ? (value.empty? ? {} : JSON.parse(value)) : value
  end

  def title
    biblio_data.present? ? biblio_data['shortTitle'] : "#{ver}#{',' if !jahr}#{' ['+jahr+']' if jahr}#{' '+publ if publ}"
  end

  def full_citation
    biblio_data.present? ? biblio_data['cite'] : title
  end

  def remote_url
    if biblio_data.present? && url = biblio_data.try(:[], 'url')
      url
    elsif biblio_data.present? && url = biblio_data['links']['self']
      url
    else
      nil
    end
  end

  def reindex_relations
    artefacts.reindex
    sources.reindex
  end

end
