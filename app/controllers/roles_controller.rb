class RolesController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: Role.all
  end
end
