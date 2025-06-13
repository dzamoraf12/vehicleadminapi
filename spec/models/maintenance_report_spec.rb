require 'rails_helper'

RSpec.describe MaintenanceReport, type: :model do
  subject { build(:maintenance_report) }

  describe "factory" do
    it "has a valid factory" do
      expect(build(:maintenance_report, user: create(:user),
                                        vehicle: create(:vehicle),
                                        status: :pendiente)).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:user).required }
    it { should belong_to(:vehicle).required }
  end

  describe "enums" do
    it { should define_enum_for(:status) }
    it { should define_enum_for(:priority) }
  end

  describe "validations" do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:priority) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:reported_at) }
  end

  context "boundary cases for reported_at" do
    it "is invalid if reported_at > current date" do
      subject.reported_at = Date.current + 1.day
      expect(subject).to be_invalid
      expect(subject.errors[:reported_at]).to include("can't be in the future")
    end
  end

  describe "scopes" do
    let!(:user) { create(:user) }
    let!(:vehicle) { create(:vehicle, user: user) }
    let!(:m1) { create(:maintenance_report, status: :pendiente, user: user, vehicle: vehicle,
                                            priority: :alta, reported_at: Date.today - 1.day) }
    let!(:m2) { create(:maintenance_report, status: :procesado, user: user, vehicle: vehicle,
                                            priority: :media, reported_at: Date.today - 2.day) }
    let!(:m3) { create(:maintenance_report, status: :rechazado, user: user, vehicle: vehicle,
                                            priority: :baja, reported_at: Date.today - 3.day) }

    context ".by_status" do
      it "returns only the maintenance_reports with the given status" do
        expect(MaintenanceReport.by_status("pendiente")).to match_array([ m1 ])
      end

      it "returns all if status is nil or empty string" do
        expect(MaintenanceReport.by_status(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_status("")).to include(m1, m2, m3)
      end
    end

    context ".by_user" do
      it "returns only the maintenance_reports of the given user" do
        u = create(:user)
        v = create(:vehicle, user: u)
        m_user = create(:maintenance_report, user: u, vehicle: v, status: :pendiente)
        expect(MaintenanceReport.by_user(u.id)).to eq([ m_user ])
      end

      it "returns all if user_id is nil or empty string" do
        expect(MaintenanceReport.by_user(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_user("")).to include(m1, m2, m3)
      end
    end

    context ".by_vehicle" do
      it "returns only the maintenance_reports for the given vehicle" do
        v = create(:vehicle)
        m_vehicle = create(:maintenance_report, vehicle: v, user: user, status: :pendiente)
        expect(MaintenanceReport.by_vehicle(v.id)).to eq([ m_vehicle ])
      end

      it "returns all if vehicle_id is nil or empty string" do
        expect(MaintenanceReport.by_vehicle(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_vehicle("")).to include(m1, m2, m3)
      end
    end

    context ".by_priority" do
      it "returns only the maintenance_reports with the given priority" do
        expect(MaintenanceReport.by_priority("alta")).to match_array([ m1 ])
      end

      it "returns all if priority is nil or empty string" do
        expect(MaintenanceReport.by_priority(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_priority("")).to include(m1, m2, m3)
      end
    end

    context ".by_reported_at range date" do
      it "returns only the maintenance_reports within the given date range" do
        expect(MaintenanceReport.by_reported_at(Date.current - 1.day..Date.current)).to match_array([ m1 ])
      end

      it "returns all if date range is nil or empty" do
        expect(MaintenanceReport.by_reported_at(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_reported_at("")).to include(m1, m2, m3)
      end
    end
  end

  describe ".filter" do
    let!(:u1) { create(:user) }
    let!(:u2) { create(:user) }
    let!(:v1) { create(:vehicle, user: u1) }
    let!(:v2) { create(:vehicle, user: u2) }
    let!(:m1) { create(:maintenance_report, user: u1, vehicle: v1, status: :pendiente,
                                            reported_at: Date.today - 1.day, priority: :baja) }
    let!(:m2) { create(:maintenance_report, user: u2, vehicle: v2, status: :procesado,
                                            reported_at: Date.today - 10.day, priority: :baja) }
    let!(:m3) { create(:maintenance_report, user: u1, vehicle: v2, status: :rechazado,
                                            reported_at: Date.today - 5.day, priority: :alta) }

    it "filters by status" do
      filters = { status: "pendiente" }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1 ])
    end

    it "filters by user" do
      filters = { user_id: u1.id }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1, m3 ])
    end

    it "filters by vehicle" do
      filters = { vehicle_id: v1.id }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1 ])
    end

    it "filters by priority" do
      filters = { priority: "alta" }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m3 ])
    end

    it "filters by reported_at range" do
      filters = { reported_at: Date.current - 1.day..Date.current }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1 ])
    end

    it "returns all if no filters are applied" do
      filters = {}
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1, m2, m3 ])
    end

    it "returns an empty array if no records match the filters" do
      filters = { status: "non_existent_status" }
      result = MaintenanceReport.filter(filters)
      expect(result).to be_empty
    end

    it "returns all if filters are nil" do
      filters = nil
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1, m2, m3 ])
    end

    it "returns all if filters are empty" do
      filters = {}
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1, m2, m3 ])
    end

    it "returns an empty array if no records match the filters" do
      filters = { status: "non_existent_status" }
      result = MaintenanceReport.filter(filters)
      expect(result).to be_empty
    end
  end
end
