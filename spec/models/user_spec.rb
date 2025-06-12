require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { create(:user) }
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:user)).to be_valid
    end
  end

  describe "role methods" do
    let(:admin_user) { build(:user, role: "admin") }
    let(:technician_user) { build(:user, role: "tecnico") }
    let(:driver_user) { build(:user, role: "chofer") }

    it "returns true for admin? method" do
      expect(admin_user.admin?).to be true
      expect(technician_user.admin?).to be false
      expect(driver_user.admin?).to be false
    end

    it "returns true for technician? method" do
      expect(technician_user.technician?).to be true
      expect(admin_user.technician?).to be false
      expect(driver_user.technician?).to be false
    end

    it "returns true for driver? method" do
      expect(driver_user.driver?).to be true
      expect(admin_user.driver?).to be false
      expect(technician_user.driver?).to be false
    end
  end
end
