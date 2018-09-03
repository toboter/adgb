# t.string    :name
# t.integer   :sources_count

class Archive < ApplicationRecord
  has_many :sources, dependent: :destroy


end