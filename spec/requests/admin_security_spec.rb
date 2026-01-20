require "rails_helper"
RSpec.describe "Admin access", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  it "forbids normal user" do
    login(user)
    get "/admin/users"
    expect(response).to have_http_status(:forbidden)
  end

  it "allows admin" do
    login(admin)
    get "/admin/users"
    expect(response).to have_http_status(:ok)
  end
end
