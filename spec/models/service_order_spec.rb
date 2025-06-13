require "rails_helper"

RSpec.describe ServiceOrder, type: :model do
  let!(:admin) { create(:user, role: :admin) }
  let!(:driver) { create(:user, role: :chofer) }
  let!(:vehicle) { create(:vehicle, status: :disponible, user: admin) }
  let!(:maintenance_report_base) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                               vehicle: vehicle, user: driver) }

  let!(:vehicle1) { create(:vehicle, status: :disponible, user: admin) }
  let!(:vehicle2) { create(:vehicle, status: :disponible, user: admin) }
  let!(:vehicle3) { create(:vehicle, status: :disponible, user: admin) }
  let!(:maintenance_report1) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                            vehicle: vehicle1, user: driver) }
  let!(:maintenance_report2) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                            vehicle: vehicle2, user: driver) }
  let!(:maintenance_report3) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                            vehicle: vehicle3, user: driver) }
  let!(:maintenance_report4) { create(:maintenance_report, status: :procesado, priority: :baja,
                                                            vehicle: vehicle1, user: driver) }
  let!(:order1) { create(:service_order, status: :abierta, vehicle: vehicle1,
                                          maintenance_report: maintenance_report1) }
  let!(:order2) { create(:service_order, status: :en_progreso, vehicle: vehicle2,
                                          maintenance_report: maintenance_report2) }
  let!(:order3) { create(:service_order, status: :abierta, vehicle: vehicle3,
                                          maintenance_report: maintenance_report3) }
  let!(:old_order) { create(:service_order, status: :cerrada, vehicle: vehicle1,
                                            maintenance_report: maintenance_report4,
                                            created_at:  2.days.ago) }

  subject { build(:service_order, vehicle: vehicle, maintenance_report: maintenance_report_base) }

  describe "factory" do
    it "has a valid factory" do
      expect(subject).to be_valid
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:vehicle) }
    it { is_expected.to belong_to(:maintenance_report) }
  end

  describe "enums" do
    it do
      is_expected.to define_enum_for(:status)
        .with_values(abierta: 0, en_progreso: 1, cerrada: 2)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:estimated_cost) }
    it do
      is_expected.to validate_numericality_of(:estimated_cost)
        .is_greater_than_or_equal_to(0)
    end
  end

  context "boundary cases for estimated_cost" do
    it "is invalid if estimated_cost is negative" do
      subject.estimated_cost = -1
      expect(subject).to be_invalid
      expect(subject.errors[:estimated_cost]).
        to include("must be greater than or equal to 0")
    end

    it "is valid if estimated_cost is zero" do
      subject.estimated_cost = 0
      expect(subject).to be_valid
    end
  end

  describe "scopes" do
    context ".by_status" do
      it "returns only orders with the given status" do
        expect(ServiceOrder.by_status("abierta")).to match_array([ order1, order3 ])
      end

      it "returns all if status is nil or blank" do
        expect(ServiceOrder.by_status(nil)).to include(order1, order2, order3, old_order)
        expect(ServiceOrder.by_status("")).to include(order1, order2, order3, old_order)
      end
    end

    context ".by_vehicle" do
      it "returns only orders for the given vehicle" do
        v = order2.vehicle
        expect(ServiceOrder.by_vehicle(v.id)).to eq([ order2 ])
      end

      it "returns all if vehicle_id is nil or blank" do
        expect(ServiceOrder.by_vehicle(nil)).to include(order1, order2, order3, old_order)
        expect(ServiceOrder.by_vehicle("")).to include(order1, order2, order3, old_order)
      end
    end

    context ".by_created_at" do
      let(:range) { 1.day.ago.beginning_of_day..Time.current.end_of_day }

      it "returns only orders created within the given range" do
        expect(ServiceOrder.by_created_at(range)).to match_array([ order1, order2, order3 ])
      end

      it "returns all if created_at param is nil or blank" do
        expect(ServiceOrder.by_created_at(nil)).to include(order1, order2, order3, old_order)
        expect(ServiceOrder.by_created_at("")).to include(order1, order2, order3, old_order)
      end
    end
  end

  describe ".filter" do
    it "delegates to FilteringService with correct params" do
      fake_service = instance_double("FilteringService", filter: :result)
      expect(FilteringService).to receive(:new)
        .with(ServiceOrder, { by_status: "abierta", by_vehicle: vehicle1.id, by_created_at: nil }, [])
        .and_return(fake_service)

      expect(ServiceOrder.filter({ status: "abierta", vehicle_id: vehicle1.id }, [])).to eq(:result)
    end

    it "returns all when params blank" do
      expect(ServiceOrder.filter).to match_array([ order1, order2, order3, old_order ])
    end
  end
end
