require 'rails_helper'

RSpec.describe "PaletteRecords#update", type: :request do
  let(:company) { create(:company) }

  let(:shipper) { create(:user, :shipper, company: company) }
  let(:carrier) { create(:user, :carrier, company: company) }
  let(:admin)   { create(:user, :admin, company: company) }

  let(:user_connection) do
    create(:user_connection,
      shipper: shipper,
      carrier: carrier,
      status: :accepted
    )
  end

  let(:palette_record) do
    create(:palette_record,
      company: company,
      user: shipper,
      shipper: shipper,
      carrier: carrier,
      recipient: recipient,
      user_connection: user_connection,
      loaded: 20,
      rendered: 10
    )
  end

  let(:headers) { auth_headers(shipper) }

  describe "PATCH /palette_records/:id" do
    context "with accepted connection" do
      it "updates the record" do
        patch "/palette_records/#{palette_record.id}",
          params: {
            palette_record: { loaded: 50 }
          },
          headers: headers

        expect(response).to have_http_status(:ok)
        expect(palette_record.reload.loaded).to eq(50)
      end
    end

    context "with pending connection" do
      before do
        palette_record.user_connection.update!(status: :pending)
      end

      it "forbids update" do
        patch "/palette_records/#{palette_record.id}",
          params: {
            palette_record: { loaded: 50 }
          },
          headers: headers

        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)["error"])
          .to eq("Connexion non autorisée")
      end
    end

    context "when user tries to change carrier" do
      let(:other_carrier) { create(:user, :carrier) }

      it "ignores forbidden params" do
        patch "/palette_records/#{palette_record.id}",
          params: {
            palette_record: { carrier_id: other_carrier.id }
          },
          headers: headers

        expect(response).to have_http_status(:ok)
        expect(palette_record.reload.carrier_id).to eq(carrier.id)
      end
    end

    context "admin user" do
      let(:headers) { auth_headers(admin) }

      it "can update any record in company" do
        patch "/palette_records/#{palette_record.id}",
          params: {
            palette_record: { rendered: 25 }
          },
          headers: headers

        expect(response).to have_http_status(:ok)
        expect(palette_record.reload.rendered).to eq(25)
      end
    end
  end
end
