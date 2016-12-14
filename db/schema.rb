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

ActiveRecord::Schema.define(version: 20161213113545) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "artefact_people", force: :cascade do |t|
    t.string   "person"
    t.string   "titel"
    t.string   "n_bab_rel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["n_bab_rel"], name: "index_artefact_people_on_n_bab_rel", using: :btree
  end

  create_table "artefact_photos", force: :cascade do |t|
    t.string   "p_bab_rel"
    t.string   "ph"
    t.integer  "ph_nr"
    t.string   "ph_add"
    t.string   "position"
    t.string   "p_rel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["p_bab_rel"], name: "index_artefact_photos_on_p_bab_rel", using: :btree
    t.index ["p_rel"], name: "index_artefact_photos_on_p_rel", using: :btree
  end

  create_table "artefact_references", force: :cascade do |t|
    t.string   "ver"
    t.string   "publ"
    t.string   "jahr"
    t.string   "seite"
    t.string   "b_bab_rel"
    t.string   "ph_rel"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["b_bab_rel"], name: "index_artefact_references_on_b_bab_rel", using: :btree
    t.index ["ph_rel"], name: "index_artefact_references_on_ph_rel", using: :btree
  end

  create_table "artefacts", force: :cascade do |t|
    t.string   "bab_rel"
    t.string   "grabung"
    t.integer  "bab"
    t.string   "bab_ind"
    t.string   "b_join"
    t.string   "b_korr"
    t.string   "mus_sig"
    t.integer  "mus_nr"
    t.string   "mus_ind"
    t.string   "m_join"
    t.string   "m_korr"
    t.string   "kod"
    t.string   "grab"
    t.string   "text"
    t.string   "sig"
    t.integer  "diss"
    t.integer  "mus_id"
    t.string   "standort_alt"
    t.string   "standort"
    t.string   "mas1"
    t.string   "mas2"
    t.string   "mas3"
    t.text     "f_obj"
    t.string   "abklatsch"
    t.string   "abguss"
    t.string   "fo_tell"
    t.string   "fo1"
    t.string   "fo2"
    t.string   "fo3"
    t.string   "fo4"
    t.text     "fo_text"
    t.integer  "utmx"
    t.integer  "utmxx"
    t.integer  "utmy"
    t.integer  "utmyy"
    t.text     "inhalt"
    t.string   "period"
    t.string   "arkiv"
    t.string   "text_in_archiv"
    t.string   "jahr"
    t.string   "datum"
    t.string   "zeil2"
    t.string   "zeil1"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.string   "gr_datum"
    t.string   "gr_jahr"
    t.index ["bab_rel"], name: "index_artefacts_on_bab_rel", unique: true, using: :btree
  end

  create_table "photos", force: :cascade do |t|
    t.string   "ph_rel"
    t.string   "ph"
    t.integer  "ph_nr"
    t.string   "ph_add"
    t.string   "ph_datum"
    t.text     "ph_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ph_rel"], name: "index_photos_on_ph_rel", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "email"
    t.string   "birthday"
    t.string   "gender"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
