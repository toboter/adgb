module ArtefactsHelper
  def linebreak_before_and_show_if_exists(object, br="<br>")
  	if object.present?
	  br ? (br+object).html_safe : object
	end
  end
 
  def with_description(object, desc)
  	content_tag(:strong, desc+': ')+object if object.present?
  end
end
