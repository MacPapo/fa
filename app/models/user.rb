class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :nickname, presence: true, uniqueness: true
  normalizes :nickname, with: ->(e) { e.strip.downcase }

  def avatar
    nickname.first.upcase
  end
end
