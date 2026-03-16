class Contact < ApplicationRecord
  include FtsSearchable, Avatarable

  broadcasts_refreshes          # turbo

  enum :kind, { person: 0, company: 1 }

  has_many :participations, dependent: :destroy
  has_many :jobs, through: :participations

  validates :first_name, presence: true, if: :person?
  validates :last_name, presence: true, if: :person?
  validates :company_name, presence: true, if: :company?

  normalizes :email, with: ->(e) { e.strip.downcase }
  normalizes :vat_number, :tax_id, with: ->(e) { e.strip.upcase }

  # Display Name Virtual column
end
