require "rails_helper"

RSpec.describe "MaintenanceReports", type: :request do
  def json
    JSON.parse(response.body)
  end

  let!(:user_admin) { create(:user) }
  let!(:user_tech) { create(:user) }
  let!(:user_driver) { create(:user, role: :chofer) }
  let!(:vehicle1) { create(:vehicle, license_plate: "AAA111", status: :disponible, user: user_admin) }
  let!(:maintenance_report1) { create(:maintenance_report, vehicle: vehicle1, user: user_tech, priority: :alta, status: :pendiente) }
  let!(:maintenance_report2) { create(:maintenance_report, vehicle: vehicle1, user: user_tech, priority: :media, status: :procesado) }
  let!(:maintenance_report3) { create(:maintenance_report, vehicle: vehicle1, user: user_driver, priority: :baja, status: :rechazado) }
  let(:headers) { Devise::JWT::TestHelpers.auth_headers({}, user_admin) }
  let(:driver_headers) { Devise::JWT::TestHelpers.auth_headers({}, user_driver) }

  describe "GET /maintenance_reports" do
    xit "returns all maintenance reports when no filters are given" do
      get maintenance_reports_url, headers: headers
      expect(response).to have_http_status(:ok)
      statuses = json.map { |v| v["status"] }
      expect(statuses).to match_array(%w[pendiente procesado rechazado])
    end

    xit "filters by status" do
      get maintenance_reports_url, params: { status: "pendiente" }, headers: headers
      statuses = json.map { |v| v["status"] }
      expect(statuses).to match_array(%w[pendiente])
    end

    xit "filters by user_id" do
      get maintenance_reports_url, params: { user_id: user_tech.id }, headers: headers
      statuses = json.map { |v| v["status"] }
      expect(statuses).to eq([ "procesado" ])
    end

    xit "filters by vehicle" do
      get maintenance_reports_url, params: { vehicle_id: vehicle1.id }, headers: headers
      statuses = json.map { |v| v["status"] }
      expect(statuses).to match_array(%w[pendiente procesado rechazado])
    end

    xit "filters by priority" do
      get maintenance_reports_url, params: { priority: "alta" }, headers: headers
      statuses = json.map { |v| v["priority"] }
      expect(statuses).to match_array(%w[alta])
    end

    xit "filters by reported_at date range" do
      get maintenance_reports_url, params: { reported_at: "#{maintenance_report1.reported_at.to_date}..#{maintenance_report2.reported_at.to_date}" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json.size).to eq(2)
    end

    xit "returns empty array when no reports match filters" do
      get maintenance_reports_url, params: { status: "nonexistent" }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(json).to eq([])
    end

    xit "returns 400 for invalid date range format" do
      get maintenance_reports_url, params: { reported_at: "invalid_date_range" }, headers: headers
      expect(response).to have_http_status(:bad_request)
      expect(json["error"]).to eq("Invalid date range format")
    end

    xit "paginates results when per_page is provided" do
      get maintenance_reports_url, params: { per_page: 2 }, headers: headers
      expect(json.size).to eq(2)
    end

    xit "uses MaintenanceReportBlueprint for serialization" do
      allow(MaintenanceReportBlueprint).to receive(:render_as_hash).and_call_original
      get maintenance_reports_url, headers: headers
      expect(MaintenanceReportBlueprint).to have_received(:render_as_hash)
    end

    xit "returns user not logged in error" do
      get maintenance_reports_url, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("User not logged in")
    end

    xit "returns 403 for unauthorized access" do
      get maintenance_reports_url, headers: driver_headers
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("You are not authorized to access this resource")
    end
  end

  describe "POST /maintenance_reports" do
    let(:valid_attributes) { attributes_for(:maintenance_report, vehicle: vehicle1, user: user_tech) }

    xit "creates a maintenance report with valid params" do
      expect {
        post maintenance_reports_url, params: { maintenance_report: valid_attributes },
                                      headers: driver_headers, as: :json
      }.to change(MaintenanceReport, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json["vehicle"]["license_plate"]).to eq("AAA111")
    end

    xit "returns errors with invalid params" do
      post maintenance_reports_url, params: { maintenance_report: valid_attributes.merge(reported_at: Date.today + 1.day) },
                                    headers: driver_headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error_hash"]).to include("reported_at")
    end

    xit "ignores unpermitted params" do
      post maintenance_reports_url, params: { maintenance_report: valid_attributes.merge(foo: "bar") },
                                    headers: driver_headers, as: :json
      expect(response).to have_http_status(:created)
      expect(MaintenanceReport.last.attributes).not_to include("foo")
    end

    xit "returns user not logged in error" do
      post maintenance_reports_url, params: { maintenance_report: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("User not logged in")
    end

    xit "returns 403 for unauthorized access" do
      post maintenance_reports_url, params: { maintenance_report: valid_attributes }, headers: headers
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("You are not authorized to access this resource")
    end
  end

  describe "GET /maintenance_reports/:id" do
    xit "returns the maintenance report when it exists" do
      get maintenance_report_url(maintenance_report1.id), headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(json["id"]).to eq(maintenance_report1.id)
    end

    xit "returns 404 when the maintenance report does not exist" do
      get maintenance_report_url(0), headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    xit "returns user not logged in error" do
      get maintenance_report_url(maintenance_report1.id), as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    xit "returns 403 for unauthorized access" do
      get maintenance_report_url(maintenance_report1.id), headers: driver_headers
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("You are not authorized to access this resource")
    end
  end

  describe "PATCH /maintenance_reports/:id" do
    let(:valid_attributes) { attributes_for(:maintenance_report, vehicle: vehicle1, user: user_tech) }

    xit "updates the maintenance report with valid params" do
      patch maintenance_report_url(maintenance_report1.id), params: { maintenance_report: { description: "New Description" } },
                                                            headers: headers, as: :json
      expect(response).to have_http_status(:ok)
      expect(maintenance_report1.reload.description).to eq("New Description")
    end

    xit "returns errors with invalid params" do
      patch maintenance_report_url(maintenance_report1.id), params: { maintenance_report: { reported_at: Date.today + 1.day } },
                                                            headers: headers, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      expect(json["error_hash"]).to include("year")
    end

    xit "returns 404 when the maintenance report does not exist" do
      patch maintenance_report_url(0), params: { maintenance_report: valid_attributes },
                                       headers: headers, as: :json
      expect(response).to have_http_status(:not_found)
    end

    xit "returns user not logged in error" do
      patch maintenance_report_url(maintenance_report1.id), params: { maintenance_report: valid_attributes }, as: :json
      expect(response).to have_http_status(:unauthorized)
      expect(json["error"]).to eq("User not logged in")
    end

    xit "returns 403 for unauthorized access" do
      patch maintenance_report_url(maintenance_report1.id), params: { maintenance_report: valid_attributes },
                                                            headers: driver_headers
      expect(response).to have_http_status(:forbidden)
      expect(json["error"]).to eq("You are not authorized to access this resource")
    end
  end
end
