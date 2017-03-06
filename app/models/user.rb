class User < ApplicationRecord
  has_secure_token
  has_many :accessibilities, foreign_key: :accessor_id
  has_many :artefacts, through: :accessibilities, source: :accessable, source_type: "Artefact"
  has_many :created_accessibilities, class_name: 'Accessibility', foreign_key: :creator_id
  has_many :created_artefacts, class_name: 'Artefact', foreign_key: :creator_id
  
  def name
    read_attribute(:name).presence || email
  end
  
  def can_manage?
    scope ? scope.include?('write') : false
  end

end
