# Minimal ActiveModel::Serializer-compatible shim (replaces the AMS gem for Rails 7.1+).
# Supports attribute + association DSL used by Babili/ADGB serializers and :json root wrapping.
module ActiveModel
  module Serializers
    # No-op compatibility for legacy `include ActiveModel::Serializers`.
  end

  class Serializer
    class_attribute :_attribute_map, instance_writer: false, default: []
    class_attribute :_type_name, instance_writer: false

    class << self
      def inherited(subclass)
        super
        subclass._attribute_map = _attribute_map.dup
        subclass._type_name = _type_name
      end

      def attribute(name, key: nil, **opts, &block)
        key_sym = (key || name).to_sym
        # AMS defines a reader for block attributes; later definitions replace earlier ones
        # (e.g. `attributes :foo` then `attribute :foo do ... end`).
        define_method(name, &block) if block

        condition_if = opts[:if]
        condition_unless = opts[:unless]
        self._attribute_map = _attribute_map.reject { |(k, _)| k == key_sym }
        self._attribute_map += [[
          key_sym,
          -> {
            if condition_if
              ok = condition_if.is_a?(Symbol) ? public_send(condition_if) : instance_exec(&condition_if)
              return nil unless ok
            end
            if condition_unless
              skip = condition_unless.is_a?(Symbol) ? public_send(condition_unless) : instance_exec(&condition_unless)
              return nil if skip
            end
            send(name)
          }
        ]]
      end

      def attributes(*names)
        names.each { |name| attribute(name) }
      end

      def type(name)
        self._type_name = name
      end

      def has_many(name, serializer: nil, each_serializer: nil, **_opts, &block)
        ser = each_serializer || serializer
        attribute(name) do
          records = block ? instance_exec(&block) : object.public_send(name)
          next [] if records.nil?
          records = Array(records)
          if ser
            records.map { |r| ser.new(r, instance_options).as_json }
          else
            records.map { |r| r.as_json }
          end
        end
      end

      def has_one(name, serializer: nil, **_opts, &block)
        attribute(name) do
          record = block ? instance_exec(&block) : object.public_send(name)
          next nil if record.nil?
          serializer ? serializer.new(record, instance_options).as_json : record.as_json
        end
      end

      def belongs_to(name, serializer: nil, **_opts, &block)
        has_one(name, serializer: serializer, &block)
      end

      def serialize_resource(resource, options = {})
        new(resource, options).as_json
      end

      def serialize_collection(collection, options = {})
        collection.map { |resource| serialize_resource(resource, options) }
      end

      def root_key(plural: false)
        base = name.demodulize.sub(/Serializer\z/, "").underscore
        plural ? base.pluralize : base
      end
    end

    attr_reader :object, :instance_options

    def initialize(object, instance_options = {})
      @object = object
      @instance_options = instance_options || {}
    end

    # AMS default serialization_scope is :current_user; serializers call scope / current_user.
    def scope
      instance_options[:scope]
    end

    def current_user
      scope
    end

    def method_missing(method_name, *args, &block)
      if object.respond_to?(method_name)
        object.public_send(method_name, *args, &block)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      object.respond_to?(method_name, include_private) || super
    end

    def serializable_hash(_options = nil)
      self.class._attribute_map.each_with_object({}) do |(key, block), hash|
        hash[key] = coerce(instance_exec(&block))
      end
    end

    def as_json(_options = nil)
      serializable_hash
    end

    private

    def coerce(value)
      case value
      when ActiveModel::Serializer
        value.as_json
      when Array
        value.map { |entry| coerce(entry) }
      when Hash
        value.transform_values { |entry| coerce(entry) }
      else
        value
      end
    end
  end
end
