class AddDataModelsForMatching < ActiveRecord::Migration[7.2]
  def change
    create_table :user_matches do |t|
      t.references :user, foreign_key: true, null: false
      t.datetime :opt_in_sms_sent
      t.string :opt_in_response
      t.boolean :opt_in_result
      t.datetime :topic_sms_sent
      t.string :topic_response
      t.boolean :matching_started, default: false
      t.boolean :matching_completed, default: false
      t.references :matched_user, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
