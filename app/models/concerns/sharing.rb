# Local replacement for the unmaintained shareable_models gem.
# Class macros: +sharer+ / +shareable+; keep association and method names stable
# for Visibility, grants, and User overrides.
module Sharing
  module ClassMethods
    def shareable(options = {})
      include Sharing::Shareable

      has_many :shared_with, as: :resource, class_name: "ShareModel"

      class_attribute :shareable_options, instance_writer: false
      self.shareable_options = options
    end

    def sharer
      include Sharing::Sharer

      has_many :shared_resources, as: :shared_from, class_name: "ShareModel"
      has_many :shared_with_me, as: :shared_to, class_name: "ShareModel"
    end
  end

  module Sharer
    def sharer?
      true
    end

    def share(resource, to, edit = false)
      check_resource(resource)
      check_sharer(to)
      return false unless can_edit?(resource)

      shared_resources.build(
        shared_to: to,
        resource: resource,
        edit: edit
      )
      save!
    end

    def share_with_me(resource, from, edit = false)
      check_resource(resource)
      check_sharer(from)
      from.share(resource, self, edit)
    end

    def throw_out(resource, sharer, edit = true)
      check_resource(resource)
      check_sharer(sharer)
      return false if (edit && !can_edit?(resource)) || resource.shareable_owner == sharer

      relation = resource.shared_with.find_by(shared_to: sharer)
      relation.nil? ? true : relation.destroy.destroyed?
    end

    def leave(resource)
      throw_out(resource, self, false)
    end

    def can_edit?(resource)
      check_resource(resource)
      resource.shareable_owner == self ||
        shared_with_me.where(edit: true).exists?(resource: resource)
    end

    def can_read?(resource)
      check_resource(resource)
      resource.shareable_owner == self ||
        shared_with_me.exists?(resource: resource)
    end

    def allow_edit(resource, to)
      return false unless can_edit?(resource)
      return true if to.can_edit?(resource)

      share_resource = shared_resources.find_by(shared_to: to, resource: resource)
      if share_resource.nil?
        share(resource, to, true)
      else
        share_resource.update(edit: true)
      end
    end

    def prevent_edit(resource, to)
      return false unless can_edit?(resource)

      share_resource = shared_resources.find_by(shared_to: to, resource: resource)
      return true if share_resource.nil?

      share_resource.update(edit: false)
    end

    private

    def check_resource(resource)
      raise "#{resource} class must include Shareable module" unless resource.respond_to?(:shareable?)
    end

    def check_sharer(sharer)
      raise "#{sharer} class must include Sharer module" unless sharer.respond_to?(:sharer?)
    end
  end

  module Shareable
    def shareable?
      true
    end

    def shareable_owner
      return nil if shareable_options.nil? || shareable_options[:owner].nil?

      send(shareable_options[:owner])
    end

    def share_it(from, to, edit = false)
      from.share(self, to, edit)
    end

    def throw_out(from, to)
      from.throw_out(self, to)
    end

    def leave_by(sharer)
      sharer.leave(self)
    end

    def editable_by?(from)
      from.can_edit?(self)
    end

    def readable_by?(from)
      from.can_read?(self)
    end

    def allow_edit(from, to)
      from.allow_edit(self, to)
    end

    def prevent_edit(from, to)
      from.prevent_edit(self, to)
    end
  end
end
