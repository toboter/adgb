class User < ApplicationRecord
  has_secure_token
  sharer

  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships
  has_many :record_activities, foreign_key: :actor_id

  validates :name, uniqueness: true

  def self.current
    Thread.current[:current_user]
  end

  def self.current=(usr)
    Thread.current[:current_user] = usr
  end

  def self.search(search)
    wildcard_search = "%#{search}%"
    where("name LIKE ?", wildcard_search)
  end

  # overrides sharer can_edit?
  def can_edit?(resource)
    check_resource(resource)
    (resource.shareable_owner == self ||
      shared_with_me.where(edit: true).exists?(edit: true, resource: resource) ||
      groups.map{|g| g.shared_with_me.where(edit: true).exists?(edit: true, resource: resource) }.include?(true) ||
      app_admin) &&
      !resource.published?
  end

  # overrides sharer can_read?
  def can_read?(resource)
    check_resource(resource)
    resource.published? ||
      resource.shareable_owner == self ||
      shared_with_me.exists?(resource: resource) ||
      groups.map{|g| g.shared_with_me.exists?(resource: resource) }.include?(true) ||
      app_admin
  end

  # extend enki
  def is_owner?
    record_activities.where(activity_type: 'Created').any? || 
    app_admin
  end

  def is_editor?
    shared_with_me.where(edit: true).any? ||
      groups.map{|g| g.shared_with_me.where(edit: true).any?}.include?(true) || 
      app_admin
  end
  # ..

  def is_admin?
    app_admin
  end

  def is_creator?
    app_creator
  end

  def is_publisher?
    app_publisher
  end

  def group_list
    groups.map(&:name).join("; ")
  end
  
  def group_list=(names)
    self.groups = names.reject { |c| c.empty? }.split(";").flatten.map do |n|
      Group.where(name: n).first
    end
  end

end