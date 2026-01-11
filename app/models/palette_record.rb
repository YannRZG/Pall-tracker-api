class PaletteRecord < ApplicationRecord
  belongs_to :company
  belongs_to :shipper, class_name: "User", optional: true
  belongs_to :carrier, class_name: "User", optional: true
  belongs_to :recipient, class_name: "User", optional: true

  # Dettes
  def loading_debt; loaded.to_i - rendered.to_i; end
  def delivery_debt; delivered.to_i - returned.to_i; end

  scope :for_shipper, ->(user) { where(shipper_id: user.id) }
  scope :for_carrier, ->(user) { where(carrier_id: user.id) }
  scope :for_recipient, ->(user) { where(recipient_id: user.id) }

  # Group by company (utile pour DebtDashboardView)
  scope :group_by_company, ->(role) {
    group("#{role}_id")
      .select("#{role}_id as user_id, SUM(loaded - rendered) as loading_debt, SUM(delivered - returned) as delivery_debt, COUNT(*) as transports_count")
  }
end
