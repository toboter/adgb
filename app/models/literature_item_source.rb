class LiteratureItemSource < ApplicationRecord
  belongs_to :literature_item
  belongs_to :source

  after_commit :reindex_source

  def reindex_source
    source.try(:reindex)
  end
end
