module ArtefactsHelper
  def linebreak_before_and_show_if_exists(object, br="<br>")
  	if object.present?
	  br ? (br+object).html_safe : object
	end
  end
 
  def with_description(object, desc)
  	content_tag(:strong, desc)+object if object.present?
  end
  
  def table_row(object, label)
    content_tag :tr do
      concat content_tag :th, label+':'
      concat content_tag :td, object
    end if object.present?
  end
end
