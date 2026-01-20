class DebtsController < ApplicationController
  before_action :authenticate_user!

  def index
    Rails.logger.info "USER ROLE 👉 #{current_user.role.inspect}"
    data = DebtDashboardService.new(current_user).call
    render json: data
  end
end
