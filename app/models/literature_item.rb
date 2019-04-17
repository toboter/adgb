class LiteratureItem < ApplicationRecord

  has_many :artefact_references
  has_many :artefacts, through: :artefact_references
  has_many :literature_item_sources
  has_many :sources, through: :literature_item_sources

  validates :ver, uniqueness: { scope: [:jahr, :publ] }
  validates :jahr, uniqueness: { scope: [:ver, :publ] }
  validates :publ, uniqueness: { scope: [:jahr, :ver] }

  validates :biblio_data, uniqueness: true

  def biblio_data=(value)
    self[:biblio_data] = value.is_a?(String) ? JSON.parse(value) : value
  end

  def title
    if biblio_data.present?
      biblio_data['citation']
    else
      "#{ver}#{',' if !jahr}#{' ['+jahr+']' if jahr}#{' '+publ if publ}"
    end
  end

end