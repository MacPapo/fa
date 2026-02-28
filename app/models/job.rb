class Job < ApplicationRecord
  include FtsSearchable

  belongs_to :location, optional: true

  validates :date, presence: true

  scope :with_video, -> { where(with_video: true) }
  scope :recent, -> { order(date: :desc) }
end
