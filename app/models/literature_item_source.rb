class LiteratureItemSource < ApplicationRecord
  belongs_to :literature_item
  belongs_to :source, touch: true
end
