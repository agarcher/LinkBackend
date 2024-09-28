class User < ApplicationRecord
  validates :phone_number, presence: true, uniqueness: true
  validates :name, presence: true
end
