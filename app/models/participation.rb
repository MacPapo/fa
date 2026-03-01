class Participation < ApplicationRecord
  belongs_to :job
  belongs_to :contact

  validates :role, presence: true
end
