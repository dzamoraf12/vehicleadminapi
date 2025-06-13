require "rails_helper"

RSpec.describe "ServiceOrders", type: :request do
  def json
    JSON.parse(response.body)
  end

  let!(:admin) { create(:user, role: :admin) }
  let!(:driver) { create(:user, role: :chofer) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, admin) }
  let(:driver_headers) { Devise::JWT::TestHelpers.auth_headers({}, driver) }
  let!(:vehicle1) { create(:vehicle, status: :disponible, user: admin) }
  let!(:vehicle2) { create(:vehicle, status: :disponible, user: admin) }
  let!(:vehicle3) { create(:vehicle, status: :disponible, user: admin) }
  let!(:maintenance_report1) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                            vehicle: vehicle1, user: driver) }
  let!(:maintenance_report2) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                            vehicle: vehicle2, user: driver) }
  let!(:maintenance_report3) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                            vehicle: vehicle3, user: driver) }
  let!(:order1) { create(:service_order, status: :abierta, vehicle: vehicle1,
                                          maintenance_report: maintenance_report1,
                                          created_at: 3.days.ago) }
  let!(:order2) { create(:service_order, status: :cerrada, vehicle: vehicle2,
                                          maintenance_report: maintenance_report2,
                                          created_at: 2.day.ago) }
  let!(:order3) { create(:service_order, status: :abierta, vehicle: vehicle3,
                                          maintenance_report: maintenance_report3,
                                          created_at: Time.current) }

  describe "GET /service_orders" do
    context "as admin" do
      it "returns all orders when no filters given" do
        get service_orders_url, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(3)
      end

      it "filters by status" do
        get service_orders_url, params: { status: "abierta" }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json.map { |o| o["status"] }).to match_array([ "abierta", "abierta" ])
      end

      it "filters by vehicle_id" do
        get service_orders_url, params: { vehicle_id: vehicle2.id }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json.map { |o| o["vehicle"]["id"] }).to eq([ vehicle2.id ])
      end

      it "filters by created_at range" do
        get service_orders_url,
            params: { created_at_start: 3.days.ago, created_at_end: 1.day.ago },
            headers: headers

        expect(response).to have_http_status(:ok)
        ids = json.map { |o| o["id"] }
        expect(ids).to match_array([ order1.id, order2.id ])
      end

      it "paginates results when per_page provided" do
        get service_orders_url, params: { per_page: 2 }, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json.size).to eq(2)
      end

      it "uses ServiceOrderBlueprint for serialization" do
        allow(ServiceOrderBlueprint).to receive(:render_as_hash).and_call_original
        get service_orders_url, headers: headers
        expect(ServiceOrderBlueprint).to have_received(:render_as_hash)
      end
    end

    context "as non-admin" do
      it "returns forbidden" do
        get service_orders_url, headers: driver_headers
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
