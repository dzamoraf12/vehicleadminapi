require "rails_helper"

RSpec.describe VehiclePolicy, type: :policy do
  subject { described_class.new(current_user, record) }

  let(:record) { Vehicle.new }

  context "when user is admin" do
    let(:current_user) { build_stubbed(:user, role: "admin") }

    xit { is_expected.to permit_actions([:index, :show, :create, :update, :destroy]) }
  end

  context "when user is not admin" do
    let(:current_user) { build_stubbed(:user, role: "tecnico") }

    xit { is_expected.to forbid_actions([:index, :show, :create, :update, :destroy]) }
  end

  context "scope" do
    let!(:admin)     { create(:user, role: "admin") }
    let!(:technician){ create(:user, role: "tecnico") }
    let!(:v1)        { create(:vehicle) }
    let!(:v2)        { create(:vehicle) }

    xit "admin scope returns all vehicles" do
      scope = VehiclePolicy::Scope.new(admin, Vehicle.all).resolve
      expect(scope).to match_array([v1, v2])
    end

    xit "non-admin scope returns none" do
      scope = VehiclePolicy::Scope.new(technician, Vehicle.all).resolve
      expect(scope).to be_empty
    end
  end
end
