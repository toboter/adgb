require 'active_support/concern'

module Visibility
  extend ActiveSupport::Concern

  class_methods do

    def visible_for(user)
      if user && user.is_admin?
        where([accessible_by(user), inaccessible, published].map{|s| s.arel.constraints.reduce(:and) }.reduce(:or))
      elsif user
        where([accessible_by(user), created_by(user), published].map{|s| s.arel.constraints.reduce(:and) }.reduce(:or))
      else
        published
      end
    end
    
    def accessible_by(user)
      accessors = [user]
      accessors << user.groups.to_a
      # get a reference to the join table
      sharings = ShareModel.arel_table
      # get a reference to the filtered table
      resources = self.base_class.arel_table
      # let AREL generate a complex SQL query
      where(
        ShareModel \
          .where(sharings[:resource_id].eq(resources[:id]).and(sharings[:resource_type].eq(self.base_class.name) )) \
          .where(
            accessors.flatten.map { |accessor|
              (sharings[:shared_to_id].eq(accessor.id.to_i)).and(sharings[:shared_to_type].eq(accessor.class)).to_sql
            }.join(' OR ')
          )
          .exists
      )
      # Join syntax
      # includes(:share_models).where(share_models: {id: nil})
      #   .or(includes(:share_models).where(share_models: {shared_to: accessors.flatten}))
    end

    def inaccessible
      sharings = ShareModel.arel_table
      resources = self.base_class.arel_table
      where(
        ShareModel \
          .where(sharings[:resource_id].eq(resources[:id]).and(sharings[:resource_type].eq(self.base_class.name) )) \
          .exists.not
      )
    end

    def created_by(user)
      # should be only the first record in resource.versions that should match 'create'
      activities = PaperTrail::Version.arel_table
      resources = self.base_class.arel_table
      where(
        PaperTrail::Version \
          .where(activities[:item_id].eq(resources[:id]) \
            .and(activities[:item_type].eq(self.base_class.name)) \
            .and(activities[:event].eq('create')) \
            .and(activities[:whodunnit].eq(user.id.to_s)) ) \
          .exists
      )
    end

    def published
      # should be only the last record in resource.versions that should match 'publish'
      versions = PaperTrail::Version.arel_table
      resources = self.base_class.arel_table
      where(
        PaperTrail::Version \
          .where(versions[:item_id].eq(resources[:id]) \
            .and(versions[:item_type].eq(self.base_class.name)) \
            .and(versions[:event].eq('publish')) ) \
          .exists
      ).where(resources[:locked].eq(true))
    end

  end

  included do
    shareable owner: :record_creator
    has_many :access_groups, through: :shared_with, source: :shared_to, source_type: 'Group'
    has_many :access_users, through: :shared_with, source: :shared_to, source_type: 'User'
    has_many :group_accessors, through: :access_groups, source: :users
    has_many :shares, as: :resource, class_name: 'ShareModel'
    def record_accessors
      User.find(access_users.pluck(:id) + group_accessors.pluck(:id)).uniq
    end
  end

  def published?
    (locked? && versions.last.try(:event) == 'publish') || false
  end

  def record_publisher
    User.find(versions.last.try(:whodunnit)) if published?
  end

  def created?
    versions.first.try(:event) == 'create' || false
  end

  def record_creator
    User.find(versions.first.try(:whodunnit)) if created?
  end

  def created_by?(user)
    record_creator == user
  end

  def published_by?(user)
    record_publisher == user
  end
end