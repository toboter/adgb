class AddConceptDataToTags < ActiveRecord::Migration[5.2]
  def change
    add_column  :tags, :concept_data, :jsonb, null: false, default: {}
    add_index   :tags, :concept_data, using: :gin
  end
end
