class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_super_admin!

  def index
    render json: {
      stats: {
        companies: Company.count,
        users: User.count,
        pending: SignupRequest.pending.count
      },
      signup_requests: SignupRequest.pending_requests.map do |req|
        {
          id: req.id,
          company_name: req.company_name,
          admin_email: req.admin_email,
          message: req.message,
          requested_at: req.created_at,
          status: req.status # 'pending', 'approved', 'rejected'
        }
      end
    }
  end
end
