class UserConnection < ApplicationRecord
  belongs_to :shipper, class_name: "User"
  belongs_to :carrier, class_name: "User", optional: true
  belongs_to :recipient, class_name: "User", optional: true
end
