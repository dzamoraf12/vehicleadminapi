require 'rails_helper'

RSpec.describe MaintenanceReport, type: :model do
  subject { build(:maintenance_report) }

  describe "factory" do
    it "has a valid factory" do
      expect(build(:maintenance_report, user: create(:user),
                                        vehicle: create(:vehicle))).to be_valid
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
    xit { should validate_presence_of(:description) }
    xit { should validate_presence_of(:priority) }
    xit { should validate_presence_of(:status) }
    xit { should validate_presence_of(:reported_at) }
    xit { should validate_presence_of(:vehicle) }
    xit { should validate_presence_of(:user) }
  end

  context "boundary cases for reported_at" do
    xit { should validate_datetime_of(:reported_at).is_before(Date.current) }

    xit "is invalid if reported_at > current date" do
      subject.reported_at = Date.current + 1.day
      expect(subject).to be_invalid
      expect(subject.errors[:reported_at]).to include("must be before #{Date.current}")
    end
  end

  describe "scopes" do
    let!(:m1) { create(:maintenance_report, status: :pendiente) }
    let!(:m2) { create(:maintenance_report, status: :procesado) }
    let!(:m3) { create(:maintenance_report, status: :rechazado) }

    context ".by_status" do
      xit "returns only the maintenance_reports with the given status" do
        expect(MaintenanceReport.by_status("pendiente")).to match_array([ m1 ])
      end

      xit "returns all if status is nil or empty string" do
        expect(MaintenanceReport.by_status(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_status("")).to include(m1, m2, m3)
      end
    end

    context ".by_user" do
      xit "returns only the maintenance_reports of the given user" do
        u = create(:user)
        m_user = create(:maintenance_report, user: u)
        expect(MaintenanceReport.by_user(u.id)).to eq([ m_user ])
      end

      xit "returns all if user_id is nil or empty string" do
        expect(MaintenanceReport.by_user(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_user("")).to include(m1, m2, m3)
      end
    end

    context ".by_vehicle" do
      xit "returns only the maintenance_reports for the given vehicle" do
        v = create(:vehicle)
        m_vehicle = create(:maintenance_report, vehicle: v)
        expect(MaintenanceReport.by_vehicle(v.id)).to eq([ m_vehicle ])
      end

      xit "returns all if vehicle_id is nil or empty string" do
        expect(MaintenanceReport.by_vehicle(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_vehicle("")).to include(m1, m2, m3)
      end
    end

    context ".by_priority" do
      xit "returns only the maintenance_reports with the given priority" do
        expect(MaintenanceReport.by_priority("alta")).to match_array([ m1, m2, m3 ]) # Assuming all have 'alta' priority
      end

      xit "returns all if priority is nil or empty string" do
        expect(MaintenanceReport.by_priority(nil)).to include(m1, m2, m3)
        expect(MaintenanceReport.by_priority("")).to include(m1, m2, m3)
      end
    end

    context ".by_reported_at range date" do
      xit "returns only the maintenance_reports within the given date range" do
        expect(MaintenanceReport.by_reported_at(Date.current - 1.day..Date.current)).to match_array([ m1 ])
      end

      xit "returns all if date range is nil or empty" do
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
                                            reported_at: Date.today - 1.day) }
    let!(:m2) { create(:maintenance_report, user: u2, vehicle: v2, status: :procesado) }
    let!(:m3) { create(:maintenance_report, user: u1, vehicle: v2, status: :rechazado,
                                            priority: :alta) }

    xit "filters by status" do
      filters = { status: "pendiente" }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1 ])
    end

    xit "filters by user" do
      filters = { user_id: u1.id }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1, m3 ])
    end

    xit "filters by vehicle" do
      filters = { vehicle_id: v1.id }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1 ])
    end

    xit "filters by priority" do
      filters = { priority: "alta" }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m3 ])
    end

    xit "filters by reported_at range" do
      filters = { reported_at: Date.current - 1.day..Date.current }
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1 ])
    end

    xit "returns all if no filters are applied" do
      filters = {}
      result = MaintenanceReport.filter(filters)
      expect(result).to match_array([ m1, m2, m3 ])
    end

    xit "returns an empty array if no records match the filters" do
      filters = { status: "non_existent_status" }
      result = MaintenanceReport.filter(filters)
      expect(result).to be_empty
    end

    xit "returns an empty array if filters are nil" do
      filters = nil
      result = MaintenanceReport.filter(filters)
      expect(result).to be_empty
    end

    xit "returns an empty array if filters are empty" do
      filters = {}
      result = MaintenanceReport.filter(filters)
      expect(result).to be_empty
    end

    xit "returns an empty array if no records match the filters" do
      filters = { status: "non_existent_status" }
      result = MaintenanceReport.filter(filters)
      expect(result).to be_empty
    end
  end
end
