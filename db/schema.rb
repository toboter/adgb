# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180903144233) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "archives", force: :cascade do |t|
    t.string "name"
    t.integer "sources_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "artefact_people", id: :serial, force: :cascade do |t|
    t.string "person"
    t.string "titel"
    t.string "n_bab_rel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["n_bab_rel"], name: "index_artefact_people_on_n_bab_rel"
  end

  create_table "artefact_photos", id: :serial, force: :cascade do |t|
    t.string "p_bab_rel"
    t.string "ph"
    t.integer "ph_nr"
    t.string "ph_add"
    t.string "position"
    t.string "p_rel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "source_id"
    t.index ["p_bab_rel"], name: "index_artefact_photos_on_p_bab_rel"
    t.index ["p_rel"], name: "index_artefact_photos_on_p_rel"
  end

  create_table "artefact_references", id: :serial, force: :cascade do |t|
    t.string "ver"
    t.string "publ"
    t.string "jahr"
    t.string "seite"
    t.string "b_bab_rel"
    t.string "ph_rel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["b_bab_rel"], name: "index_artefact_references_on_b_bab_rel"
    t.index ["ph_rel"], name: "index_artefact_references_on_ph_rel"
  end

  create_table "artefacts", id: :serial, force: :cascade do |t|
    t.string "bab_rel"
    t.string "grabung"
    t.integer "bab"
    t.string "bab_ind"
    t.string "b_join"
    t.string "b_korr"
    t.string "mus_sig"
    t.integer "mus_nr"
    t.string "mus_ind"
    t.string "m_join"
    t.string "m_korr"
    t.string "kod"
    t.string "grab"
    t.string "text"
    t.string "sig"
    t.integer "diss"
    t.integer "mus_id"
    t.string "standort_alt"
    t.string "standort"
    t.string "mas1"
    t.string "mas2"
    t.string "mas3"
    t.text "f_obj"
    t.string "abklatsch"
    t.string "zeichnung"
    t.string "fo_tell"
    t.string "fo1"
    t.string "fo2"
    t.string "fo3"
    t.string "fo4"
    t.text "fo_text"
    t.integer "utmx"
    t.integer "utmxx"
    t.integer "utmy"
    t.integer "utmyy"
    t.text "inhalt"
    t.string "period"
    t.string "arkiv"
    t.string "text_in_archiv"
    t.string "jahr"
    t.string "datum"
    t.string "zeil2"
    t.string "zeil1"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gr_datum"
    t.string "gr_jahr"
    t.string "slug"
    t.string "code"
    t.float "latitude"
    t.float "longitude"
    t.boolean "locked", default: false, null: false
    t.string "text_solution"
    t.index ["bab_rel"], name: "index_artefacts_on_bab_rel", unique: true
    t.index ["slug"], name: "index_artefacts_on_slug", unique: true
  end

  create_table "attachments", force: :cascade do |t|
    t.integer "source_id"
    t.string "file_url"
    t.string "html_url"
    t.string "file_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_id"], name: "index_attachments_on_file_id"
    t.index ["source_id"], name: "index_attachments_on_source_id"
  end

  create_table "comment_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "comment_anc_desc_udx", unique: true
    t.index ["descendant_id"], name: "comment_desc_idx"
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.integer "commentable_id"
    t.string "commentable_type"
    t.string "title"
    t.text "body"
    t.string "subject"
    t.integer "commentator_id", null: false
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_id", "commentable_type"], name: "index_comments_on_commentable_id_and_commentable_type"
    t.index ["commentator_id"], name: "index_comments_on_commentator_id"
  end

  create_table "friendly_id_slugs", id: :serial, force: :cascade do |t|
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.string "scope"
    t.datetime "created_at"
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id"
    t.index ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type"
  end

  create_table "groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "gid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "memberships", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id", "user_id"], name: "index_memberships_on_group_id_and_user_id", unique: true
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "photo_imports", id: :serial, force: :cascade do |t|
    t.string "ph_rel"
    t.string "ph"
    t.integer "ph_nr"
    t.string "ph_add"
    t.string "ph_datum"
    t.text "ph_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug"
    t.boolean "locked", default: false, null: false
    t.index ["ph_rel"], name: "index_photo_imports_on_ph_rel", unique: true
    t.index ["slug"], name: "index_photo_imports_on_slug", unique: true
  end

  create_table "record_activities", id: :serial, force: :cascade do |t|
    t.integer "actor_id"
    t.string "resource_type"
    t.integer "resource_id"
    t.string "activity_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id", "resource_type", "activity_type"], name: "index_record_activities_on_resource_and_activity", unique: true
    t.index ["resource_type", "resource_id"], name: "index_record_activities_on_resource_type_and_resource_id"
  end

  create_table "share_models", id: :serial, force: :cascade do |t|
    t.string "resource_type"
    t.integer "resource_id"
    t.string "shared_to_type"
    t.integer "shared_to_id"
    t.string "shared_from_type"
    t.integer "shared_from_id"
    t.boolean "edit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["resource_id", "resource_type", "shared_to_id", "shared_to_type"], name: "index_share_models_on_resource_and_shared_to", unique: true
    t.index ["resource_type", "resource_id"], name: "index_share_models_on_resource_type_and_resource_id"
    t.index ["shared_from_type", "shared_from_id"], name: "index_share_models_on_shared_from_type_and_shared_from_id"
    t.index ["shared_to_type", "shared_to_id"], name: "index_share_models_on_shared_to_type_and_shared_to_id"
  end

  create_table "source_hierarchies", id: false, force: :cascade do |t|
    t.integer "ancestor_id", null: false
    t.integer "descendant_id", null: false
    t.integer "generations", null: false
    t.index ["ancestor_id", "descendant_id", "generations"], name: "source_anc_desc_idx", unique: true
    t.index ["descendant_id"], name: "source_desc_idx"
  end

  create_table "sources", force: :cascade do |t|
    t.integer "archive_id"
    t.string "collection"
    t.string "call_number"
    t.string "temp_call_number"
    t.integer "parent_id"
    t.string "sheet"
    t.string "type"
    t.string "genuineness"
    t.string "material"
    t.string "measurements"
    t.string "title"
    t.string "labeling"
    t.string "provenance"
    t.string "period"
    t.string "author"
    t.string "size"
    t.string "contains"
    t.string "part_of"
    t.string "description"
    t.string "remarks"
    t.string "condition"
    t.string "access_restrictions"
    t.string "loss_remarks"
    t.string "location_current"
    t.string "location_history"
    t.string "state"
    t.text "history"
    t.string "relevance"
    t.string "relevance_comment"
    t.string "digitize_remarks"
    t.string "keywords"
    t.string "links"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "locked", default: false, null: false
    t.index ["archive_id"], name: "index_sources_on_archive_id"
    t.index ["call_number"], name: "index_sources_on_call_number"
    t.index ["collection"], name: "index_sources_on_collection"
    t.index ["parent_id"], name: "index_sources_on_parent_id"
    t.index ["slug"], name: "index_sources_on_slug"
  end

  create_table "taggings", id: :serial, force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.string "uuid"
    t.string "url"
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "email"
    t.string "birthday"
    t.string "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
    t.boolean "app_admin"
    t.boolean "app_commentator"
    t.boolean "app_creator"
    t.boolean "app_publisher"
    t.string "image_thumb_url"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.jsonb "object"
    t.datetime "created_at"
    t.jsonb "object_changes"
    t.string "version_name"
    t.integer "changed_characters_length"
    t.integer "total_characters_length"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
end
