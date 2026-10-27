module PaginationHelper
  def pagy_nav(pagy)
    return "".html_safe unless pagy

    pagy.series_nav(:bootstrap).html_safe
  end

  def pagy_entries(pagy, item_name: nil)
    return "".html_safe unless pagy

    pagy.info_tag(item_name: item_name).html_safe
  end
end
