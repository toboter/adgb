# t.string    :name
# t.integer   :sources_count

class Archive < ApplicationRecord
  has_many :sources, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: true

end