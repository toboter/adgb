class CreateSourcesAttachments < ActiveRecord::Migration[5.1]
  def change
    create_table :attachments do |t|
      t.integer   :source_id, index: true
      t.string    :file_url
      t.string    :html_url
      t.string    :file_id, index: true

      t.timestamps
    end
  end
end
