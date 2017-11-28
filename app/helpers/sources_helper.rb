module SourcesHelper
  # Returns a dynamic path based on the provided parameters
  def sti_source_path(type = "source", source = nil, action = nil, params = nil)
    send "#{format_sti(action, type, source)}_path", source, params
  end

  def sti_source_url(type = "source", source = nil, action = nil, params = nil)
    send "#{format_sti(action, type, source)}_url", source, params
  end

  def format_sti(action, type, source)
    action || source ? "#{format_action(action)}#{type.underscore}" : "#{type.underscore.pluralize}"
  end

  def format_action(action)
    action ? "#{action}_" : ""
  end
end
