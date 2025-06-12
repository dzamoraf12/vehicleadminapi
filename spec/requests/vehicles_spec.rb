require "rails_helper"

RSpec.describe "Vehicles", type: :request do
  # Helper to parse JSON responses
  def json
    JSON.parse(response.body)
  end

  # Test data
  let!(:user_a) { create(:user) }
  let!(:user_b) { create(:user) }
  let!(:vehicle1) { create(:vehicle, license_plate: "AAA111", status: :disponible, user: user_a) }
  let!(:vehicle2) { create(:vehicle, license_plate: "BBB222", status: :en_taller, user: user_b) }
  let!(:vehicle3) { create(:vehicle, license_plate: "CCC333", status: :disponible, user: user_a) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user_a) }

  describe "GET /vehicles" do
    it "returns all vehicles when no filters are given" do
      get vehicles_url, headers: headers
      expect(response).to have_http_status(:ok)
      plates = json.map { |v| v["license_plate"] }
      expect(plates).to match_array(%w[AAA111 BBB222 CCC333])
    end

    it "filters by status" do
      get vehicles_url, params: { status: "disponible" }, headers: headers
      plates = json.map { |v| v["license_plate"] }
      expect(plates).to match_array(%w[AAA111 CCC333])
    end

    it "filters by user_id" do
      get vehicles_url, params: { user_id: user_b.id }, headers: headers
      plates = json.map { |v| v["license_plate"] }
      expect(plates).to eq(["BBB222"])
    end

    it "filters by partial license_plate" do
      get vehicles_url, params: { license_plate: "CC" }, headers: headers
      plates = json.map { |v| v["license_plate"] }
      expect(plates).to eq(["CCC333"])
    end

    it "paginates results when per_page is provided" do
      get vehicles_url, params: { per_page: 2 }, headers: headers
      expect(json.size).to eq(2)
    end

    it "uses VehicleBlueprint for serialization" do
      allow(VehicleBlueprint).to receive(:render_as_hash).and_call_original
      get vehicles_url, headers: headers
      expect(VehicleBlueprint).to have_received(:render_as_hash)
    end

    it "returns user not logged in error" do
      get vehicles_url, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("User not logged in")
    end
  end

  describe "POST /vehicles" do
    let(:valid_attributes) { attributes_for(:vehicle, license_plate: "XYZ999") }

    it "creates a vehicle with valid params" do
      expect {
        post vehicles_url, params: { vehicle: valid_attributes }, headers: headers, as: :json
      }.to change(Vehicle, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json["license_plate"]).to eq("XYZ999")
    end

    it "returns errors with invalid params" do
      post vehicles_url, params: { vehicle: valid_attributes.merge(year: 1800) }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error_hash"]).to include("year")
    end

    it "ignores unpermitted params" do
      post vehicles_url, params: { vehicle: valid_attributes.merge(foo: "bar") }, headers: headers, as: :json
      expect(response).to have_http_status(:created)
      expect(Vehicle.last.attributes).not_to include("foo")
    end

    it "returns user not logged in error" do
      post vehicles_url, params: { vehicle: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("User not logged in")
    end
  end

  describe "GET /vehicles/:id" do
    it "returns the vehicle when it exists" do
      get vehicle_url(vehicle1.id), headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(vehicle1.id)
    end

    it "returns 404 when the vehicle does not exist" do
      get vehicle_url(0), headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "returns user not logged in error" do
      get vehicle_url(vehicle1.id), as: :json
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /vehicles/:id" do
    let(:valid_attributes) { attributes_for(:vehicle, license_plate: "XYZ999") }

    it "updates the vehicle with valid params" do
      patch vehicle_url(vehicle1.id), params: { vehicle: { make: "Toyota New" } }, headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(vehicle1.reload.make).to eq("Toyota New")
    end

    it "returns errors with invalid params" do
      patch vehicle_url(vehicle1.id), params: { vehicle: { year: 1800 } }, headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error_hash"]).to include("year")
    end

    it "returns 404 when the vehicle does not exist" do
      patch vehicle_url(0), params: { vehicle: valid_attributes }, headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    it "returns user not logged in error" do
      patch vehicle_url(vehicle1.id), params: { vehicle: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("User not logged in")
    end
  end
end
