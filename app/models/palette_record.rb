class PaletteRecord < ApplicationRecord
  belongs_to :user
  belongs_to :company
  belongs_to :user_connection

  belongs_to :shipper, class_name: "User", optional: true
  belongs_to :carrier, class_name: "User", optional: true
  belongs_to :recipient, class_name: "User", optional: true

  validate :connection_is_accepted
  validate :users_belong_to_connection

  def connection_is_accepted
    return if user_connection&.accepted?

    errors.add(:user_connection, "must be accepted before creating records")
  end

  def users_belong_to_connection
    return unless user_connection

    requester_company = user_connection.requester
    receiver_company  = user_connection.receiver
    role_code         = user_connection.role&.code

    # shipper doit être dans la company request
    if shipper.company != requester_company
      errors.add(:shipper, "must belong to requester company")
    end

    # carrier doit être dans la company receiver si la connection demande un carrier
    if carrier.present? && carrier.company != receiver_company
      errors.add(:carrier, "must belong to receiver company")
    end

    # recipient doit être dans la company receiver si la connection demande un recipient
    if recipient.present? && recipient.company != receiver_company
      errors.add(:recipient, "must belong to receiver company")
    end
  end



  # Dettes
  def loading_debt; loaded.to_i - rendered.to_i; end
  def delivery_debt; delivered.to_i - returned.to_i; end

  scope :for_shipper, ->(user) { where(shipper_id: user.id) }
  scope :for_carrier, ->(user) { where(carrier_id: user.id) }
  scope :for_recipient, ->(user) { where(recipient_id: user.id) }

  # Group by company (utile pour DebtDashboardView)
  scope :group_by_company, ->(role) {
    with_accepted_connections
      .group("#{role}_id")
      .select(
        "#{role}_id as user_id,
         SUM(loaded - rendered) as loading_debt,
         SUM(delivered - returned) as delivery_debt,
         COUNT(*) as transports_count"
      )
  }
end
