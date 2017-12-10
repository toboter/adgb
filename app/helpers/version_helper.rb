module VersionHelper
  def event_happend_for(event)
    if event == 'destroy'
      'deleted'
    elsif event == 'publish'
      'published'
    elsif event == 'reopen'
      'reopened'
    else
      event+'d'
    end
  end
end
