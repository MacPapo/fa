class User < ApplicationRecord
  include Avatarable

  has_secure_password
  has_many :sessions, dependent: :destroy

  validates :nickname, presence: true, uniqueness: true
  normalizes :nickname, with: ->(e) { e.strip.downcase }

  alias_attribute :display_name, :nickname
end
