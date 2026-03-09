class Participation < ApplicationRecord
  include FtsSearchable

  ROLES = {
    photographer: "photographer",
    client: "client",
    subject: "subject"
  }.freeze

  belongs_to :job
  belongs_to :contact

  validates :role, presence: true
  validates :contact_id, uniqueness: { scope: [ :job_id, :role ], message: "ha già questo ruolo in questo lavoro" }
end
