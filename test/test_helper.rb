ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Mark a visibility-aware record as published (locked + publish version).
  def publish_record!(record, user: users(:one))
    record.update_columns(locked: true)
    PaperTrail::Version.create!(
      item_type: record.class.base_class.name,
      item_id: record.id,
      event: "publish",
      whodunnit: user.id.to_s
    )
    record.reload
  end

  def create_record_version!(record, event:, user: users(:one))
    PaperTrail::Version.create!(
      item_type: record.class.base_class.name,
      item_id: record.id,
      event: event,
      whodunnit: user.id.to_s
    )
  end

  # Minitest 6 no longer ships Object#stub.
  def with_stubbed_method(target, method_name, returns: nil)
    singleton = target.singleton_class
    original = :"__#{method_name}_without_stub"
    singleton.alias_method original, method_name
    singleton.define_method(method_name) do |*args, **kwargs, &blk|
      if returns.respond_to?(:call)
        returns.call(*args, **kwargs, &blk)
      else
        returns
      end
    end
    yield
  ensure
    if singleton.method_defined?(original) || singleton.private_method_defined?(original)
      singleton.alias_method method_name, original
      singleton.remove_method original
    end
  end
end



