class AddMatchMessageToUserMatch < ActiveRecord::Migration[7.2]
  def change
    add_column :user_matches, :match_message, :text
  end
end
