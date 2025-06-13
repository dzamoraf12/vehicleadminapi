require "rails_helper"

RSpec.describe ServiceOrderPolicy, type: :policy do
  subject { described_class.new(current_user, record) }

  let(:record) { ServiceOrder.new }

  context "when user is admin" do
    let(:current_user) { build_stubbed(:user, role: "admin") }

    it { is_expected.to permit_actions([ :index ]) }
  end

  context "when user is not admin" do
    let(:current_user) { build_stubbed(:user, role: "tecnico") }

    it { is_expected.to forbid_actions([ :index ]) }
  end

  context "scope" do
    let!(:admin)      { create(:user, role: "admin") }
    let!(:technician) { create(:user, role: "tecnico") }
    let!(:vehicle) { create(:vehicle, status: :disponible, user: admin) }
    let!(:vehicle2) { create(:vehicle, status: :disponible, user: admin) }
    let!(:report) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                vehicle: vehicle, user: technician) }
    let!(:report2) { create(:maintenance_report, status: :pendiente, priority: :baja,
                                                vehicle: vehicle2, user: technician) }
    let!(:order1)         { create(:service_order, vehicle: vehicle, maintenance_report: report) }
    let!(:order2)         { create(:service_order, vehicle: vehicle2, maintenance_report: report2) }

    it "admin scope returns all service orders" do
      scope = ServiceOrderPolicy::Scope.new(admin, ServiceOrder.all).resolve
      expect(scope).to match_array([ order1, order2 ])
    end

    it "non-admin scope returns none" do
      scope = ServiceOrderPolicy::Scope.new(technician, ServiceOrder.all).resolve
      expect(scope).to be_empty
    end
  end
end
