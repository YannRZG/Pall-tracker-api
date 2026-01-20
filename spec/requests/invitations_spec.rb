require "rails_helper"
RSpec.describe "Invitations", type: :request do
  it "allows public access" do
    invitation = create(:invitation)

    get "/invitations/#{invitation.token}"
    expect(response).to have_http_status(:ok)
  end

  it "creates user from invitation without auth" do
    invitation = create(:invitation)

    post "/signup_from_invite", params: {
      token: invitation.token,
      password: "password",
      password_confirmation: "password"
    }

    expect(response).to have_http_status(:created)
  end
end
