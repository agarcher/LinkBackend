class User < ApplicationRecord
  validates :phone_number, presence: true, uniqueness: true
  validates :name, presence: true

  has_many :user_matches
  has_many :matched_with, class_name: "UserMatch", foreign_key: "matched_user_id"

  def first_name
    name.split(" ").first
  end
end
