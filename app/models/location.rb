class Location < ApplicationRecord
  include FtsSearchable, Avatarable

  broadcasts_refreshes          # turbo

  has_many :job_locations, dependent: :restrict_with_error
  has_many :jobs, through: :job_locations

  validates :name, presence: true
  validates :name, uniqueness: { scope: :district, message: "esiste già in questo sestiere" }

  def display_name
    return name if district.blank?

    "#{name} (#{district})"
  end
end
