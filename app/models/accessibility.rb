class Accessibility < ApplicationRecord
  belongs_to :accessable, polymorphic: true
  belongs_to :accessor, class_name: 'User'
  belongs_to :creator, class_name: 'User'
  # Todo Beim Erstellen einer Accessibility muss der creator hinzugefügt werden.
  
  validates :accessable_id, :accessable_type, :accessor_id, presence: true, on: :update
  validates :accessor_id, uniqueness: { scope: [:accessable_id, :accessable_type], message: "Object access already includes accessor." }
end