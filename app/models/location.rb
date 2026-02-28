class Location < ApplicationRecord
  include FtsSearchable

  validates :name, presence: true
  validates :city, presence: true
end
