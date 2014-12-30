class CreateTaggings < ActiveRecord::Migration
  def change
    create_table :taggings do |t|
      t.integer :tag_topic_id
      t.integer :short_url_id

      t.timestamp
    end

    add_index :taggings, :tag_topic_id
    add_index :taggings, :short_url_id
  end
end
