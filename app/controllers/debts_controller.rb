class DebtsController < ApplicationController
  before_action :authenticate_user!

  def index
    data = DebtDashboardService.new(current_user).call
    render json: data
  end
end
