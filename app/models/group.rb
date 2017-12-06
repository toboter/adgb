class Group < ApplicationRecord
  sharer

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  
  validates :name, uniqueness: { case_sensitive: false }

end