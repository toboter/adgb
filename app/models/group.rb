class Group < ApplicationRecord
  sharer

  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  
  validates :name, uniqueness: { case_sensitive: false }

  def self.search(search)
    wildcard_search = "%#{search}%"
    where("name LIKE ?", wildcard_search)
  end
end