module JsonSerializerRendering
  extend ActiveSupport::Concern

  private

  # Mimic ActiveModelSerializers adapter: :json root wrapping + optional meta.
  # Passes controller current_user as AMS-compatible scope for serializers.
  def render_with_serializer(resource, serializer: nil, each_serializer: nil, meta: nil, status: nil)
    options = serialization_options
    payload =
      if each_serializer
        { each_serializer.root_key(plural: true) => each_serializer.serialize_collection(resource, options) }
      else
        { serializer.root_key(plural: false) => serializer.serialize_resource(resource, options) }
      end
    payload[:meta] = meta if meta
    args = { json: payload }
    args[:status] = status if status
    render args
  end

  def serialization_options
    scope =
      if respond_to?(:current_user, true)
        current_user
      end
    # Some API controllers return false when unset; treat that as no scope.
    scope = nil if scope == false
    { scope: scope }
  end
end
