class UserMatch < ApplicationRecord
  belongs_to :user
  belongs_to :matched_user, class_name: "User", optional: true

  validates :user_id, presence: true
end
