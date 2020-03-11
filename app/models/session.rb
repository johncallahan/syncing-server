class Session < ApplicationRecord
  belongs_to :user, foreign_key: 'user_uuid', optional: false

  require 'resolv'
  validates :ip_address, allow_nil: true, presence: false, uniqueness: false, format: { with: Resolv::IPv4::Regex }

  def serializable_hash(options = {})
    allowed_options = [
      'uuid',
      'user_uuid',
      'ip_address',
      'user_agent',
      'created_at',
      'updated_at',
    ]

    super(options.merge(only: allowed_options))
  end

  def expired?
    updated_at > 30.days.ago
  end
end
