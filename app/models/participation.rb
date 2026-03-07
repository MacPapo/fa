class Participation < ApplicationRecord
  include FtsSearchable

  ROLES = {
    photographer: "Fotografo",
    client: "Cliente",
    subject: "Soggetto"
  }.freeze

  belongs_to :job
  belongs_to :contact

  validates :role, presence: true
  validates :contact_id, uniqueness: { scope: [ :job_id, :role ], message: "ha già questo ruolo in questo lavoro" }
end
