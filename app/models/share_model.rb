# Join row for sharing a resource with a sharer (User or Group).
# Formerly provided by the shareable_models gem.
class ShareModel < ApplicationRecord
  belongs_to :resource, polymorphic: true
  belongs_to :shared_to, polymorphic: true
  belongs_to :shared_from, polymorphic: true

  validates :resource, :shared_to, :shared_from, presence: true
  validates :resource_id, uniqueness: {
    scope: %i[resource_type shared_to_id shared_to_type]
  }
end
