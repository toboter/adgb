# t.string  :name
# t.jsonb   :data
# t.integer :creator_id
# t.timestamps

class Import < ApplicationRecord

  has_one_attached :file
  belongs_to :creator, class_name: 'User'

end