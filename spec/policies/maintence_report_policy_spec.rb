require "rails_helper"

RSpec.describe MaintenanceReportPolicy, type: :policy do
  subject { described_class.new(current_user, record) }

  let(:record) { MaintenanceReport.new }

  context "when user is admin" do
    let(:current_user) { build_stubbed(:user, role: "admin") }

    it { is_expected.to permit_actions([ :index, :show, :update ]) }
    it { is_expected.to forbid_actions([ :create ]) } # For demostration purposes is forbidden
  end

  context "when user is technician" do
    let(:current_user) { build_stubbed(:user, role: "tecnico") }

    it { is_expected.to permit_actions([ :index, :show, :create, :update ]) }
  end

  context "when user is driver" do
    let(:current_user) { build_stubbed(:user, role: "chofer") }

    it { is_expected.to permit_actions([ :create ]) }
    it { is_expected.to forbid_actions([ :index, :show, :update ]) }
  end

  # test scope when user is admin and cant create maintenance reports
  context "scope" do
    let(:current_user) { build_stubbed(:user, role: "admin") }

    it "admin scope returns all maintenance reports" do
      scope = MaintenanceReportPolicy::Scope.new(current_user, MaintenanceReport.all).resolve
      expect(scope).to match_array(MaintenanceReport.all)
    end

    let(:current_user) { build_stubbed(:user, role: "tecnico") }

    it "technician scope returns all maintenance reports" do
      scope = MaintenanceReportPolicy::Scope.new(current_user, MaintenanceReport.all).resolve
      expect(scope).to match_array(MaintenanceReport.all)
    end

    let(:current_user) { build_stubbed(:user, role: "chofer") }

    it "driver scope returns none" do
      scope = MaintenanceReportPolicy::Scope.new(current_user, MaintenanceReport.all).resolve
      expect(scope).to match_array([])
    end
  end
end
