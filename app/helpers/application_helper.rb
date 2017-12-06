module ApplicationHelper
  def title(page_title, show_header = true)
    content_for(:title) { h(page_title.to_s) }
    @show_header = show_header
  end


  def can_create?
    current_user && (current_user.app_creator || current_user.app_admin)
  end

  def can_administrate?
    current_user && current_user.app_admin
  end

  # extend Nabu
  def can_comment?
    current_user && (current_user.app_commentator || current_user.app_admin)
  end
  # end extend Nabu

  def can_publish?
    current_user && (current_user.app_publisher || current_user.app_admin)
  end
  # end extend Enki
end
