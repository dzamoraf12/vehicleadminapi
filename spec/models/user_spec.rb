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
end
