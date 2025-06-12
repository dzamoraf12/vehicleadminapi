require 'rails_helper'

RSpec.describe "MaintenanceReports", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/maintenance_reports/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/maintenance_reports/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/maintenance_reports/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/maintenance_reports/update"
      expect(response).to have_http_status(:success)
    end
  end

end
