# Resolves which records a bulk index action should touch:
# checked rows (record_ids) when present, otherwise the current search/filters.
module BulkRecordSelection
  extend ActiveSupport::Concern

  private

  def bulk_selected_records(model_class)
    visible = model_class.visible_for(current_user)
    ids = Array(params[:record_ids]).reject(&:blank?)
    return visible.where(id: ids) if ids.any?

    records = visible
    if model_class.respond_to?(:filter)
      records = records.filter_by(
        params.slice(:with_user_shared_to_like, :with_unshared_records, :with_published_records)
      )
    end

    query = (params[:search].presence || "*").to_s.gsub("+", " ").squish
    sk_results = model_class.search(
      query,
      where: { id: records.ids },
      fields: [:default_fields],
      per_page: 10_000,
      misspellings: { below: 1 }
    ) do |body|
      body[:query][:bool][:must] = { query_string: { query: query, default_operator: "and" } }
    end

    model_class.where(id: sk_results.map(&:id))
  end
end
