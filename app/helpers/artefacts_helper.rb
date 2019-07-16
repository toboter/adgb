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

  def prettify_concept_hash(values,depth=0)
    content_tag(:ul, style: "margin-left:#{depth*5}", class: 'list-unstyled') {
      values.each do |k,v|
        concat content_tag :li {
          concat(content_tag :span, "#{k.humanize}: ", class: 'text-strong')
          if v.is_a?(String) || v.is_a?(Integer)
            concat(content_tag :span, v.to_s)
          elsif v.is_a?(Array)
            concat v.inspect # prettify_concept_hash(v,depth+1)
          end
        } if v && !k.include?('id') && !k.include?('url') && !k.include?('_at') && !k.include?('creator')
      end
    } if values
  end

end
