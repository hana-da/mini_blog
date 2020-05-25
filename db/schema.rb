# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_05_25_074337) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blog_comments", force: :cascade do |t|
    t.text "content", null: false
    t.bigint "blog_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blog_id"], name: "index_blog_comments_on_blog_id"
    t.index ["user_id"], name: "index_blog_comments_on_user_id"
  end

  create_table "blogs", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", default: 0, null: false
    t.string "image"
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "user_favorite_blogs", force: :cascade do |t|
    t.bigint "blog_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["blog_id", "user_id"], name: "index_user_favorite_blogs_on_blog_id_and_user_id", unique: true
    t.index ["blog_id"], name: "index_user_favorite_blogs_on_blog_id"
    t.index ["user_id"], name: "index_user_favorite_blogs_on_user_id"
  end

  create_table "user_relationships", force: :cascade do |t|
    t.bigint "follower_id", null: false
    t.bigint "followed_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id"], name: "index_user_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_user_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_user_relationships_on_follower_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "encrypted_password", default: "", null: false
    t.text "profile", default: "", null: false
    t.text "blog_url", default: "", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "email", default: "", null: false
    t.index ["email"], name: "index_users_on_email", unique: true, where: "((email)::text <> ''::text)"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "blog_comments", "blogs"
  add_foreign_key "blog_comments", "users"
  add_foreign_key "blogs", "users"
  add_foreign_key "user_favorite_blogs", "blogs"
  add_foreign_key "user_favorite_blogs", "users"
  add_foreign_key "user_relationships", "users", column: "followed_id"
  add_foreign_key "user_relationships", "users", column: "follower_id"
end
