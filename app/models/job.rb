class Job < ApplicationRecord
  include FtsSearchable

  belongs_to :location, optional: true

  has_many :participations, dependent: :destroy
  has_many :contacts, through: :participations

  has_many :photographer_participations, -> { where(role: "Fotografo") }, class_name: "Participation"
  has_many :photographers, through: :photographer_participations, source: :contact

  has_many :client_participations, -> { where(role: "Cliente") }, class_name: "Participation"
  has_many :clients, through: :client_participations, source: :contact

  has_many :character_participations, -> { where.not(role: [ "Fotografo", "Cliente" ]) }, class_name: "Participation"
  has_many :characters, through: :character_participations, source: :contact

  validates :date, presence: true

  scope :with_video, -> { where(with_video: true) }
  scope :recent, -> { order(date: :desc) }
end
