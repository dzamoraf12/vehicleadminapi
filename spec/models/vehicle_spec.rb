require "rails_helper"

RSpec.describe Vehicle, type: :model do
  subject { build(:vehicle) }

  describe "factory" do
    it "has a valid factory" do
      expect(build(:vehicle)).to be_valid
    end
  end

  describe "associations" do
    it { should belong_to(:user).required }
  end

  describe "enums" do
    it { should define_enum_for(:status) }
  end

  describe "validations" do
    it { should validate_presence_of(:license_plate) }
    it { should validate_presence_of(:make) }
    it { should validate_presence_of(:model) }
    it { should validate_presence_of(:year) }
    it { should validate_presence_of(:status) }
    it { should validate_uniqueness_of(:license_plate).case_insensitive }

    it do
      should validate_numericality_of(:year)
        .only_integer
        .is_greater_than_or_equal_to(1900)
        .is_less_than_or_equal_to(Date.current.year + 1)
    end
  end

  context "boundary cases for year" do
    it "is invalid if year < 1900" do
      subject.year = 1899
      expect(subject).to be_invalid
      expect(subject.errors[:year]).to include("must be greater than or equal to 1900")
    end

    it "is invalid if year > current year" do
      subject.year = Date.current.year + 2
      expect(subject).to be_invalid
      expect(subject.errors[:year]).to include("must be less than or equal to #{Date.current.year + 1}")
    end
  end

  context "license_plate uniqueness and case insensitivity" do
    let!(:existing) { create(:vehicle, license_plate: "ABC123") }

    it "is invalid with duplicate license_plate (case insensitive)" do
      subject.license_plate = "abc123"
      expect(subject).to be_invalid
      expect(subject.errors[:license_plate]).to include("has already been taken")
    end
  end

  describe "scopes" do
    let!(:v1) { create(:vehicle, status: :disponible, license_plate: "ABC123", user: create(:user)) }
    let!(:v2) { create(:vehicle, status: :en_taller, user: create(:user)) }
    let!(:v3) { create(:vehicle, status: :disponible, user: create(:user)) }

    context ".by_plate" do
      it "returns only the vehicles with the given plate" do
        expect(Vehicle.by_plate("ABC123")).to match_array([v1])
      end

      it "returns all if plate is nil or empty string" do
        expect(Vehicle.by_plate(nil)).to include(v1, v2, v3)
        expect(Vehicle.by_plate("")).to include(v1, v2, v3)
      end
    end

    context ".by_status" do
      it "returns only the vehicles with the given status" do
        expect(Vehicle.by_status("disponible")).to match_array([v1, v3])
      end

      it "returns all if status is nil or empty string" do
        expect(Vehicle.by_status(nil)).to include(v1, v2, v3)
        expect(Vehicle.by_status("")).to include(v1, v2, v3)
      end
    end

    context ".by_user" do
      it "returns only the vehicles of the given user" do
        u = create(:user)
        v_user = create(:vehicle, user: u)
        expect(Vehicle.by_user(u.id)).to eq([v_user])
      end

      it "returns all if user_id is nil or empty string" do
        expect(Vehicle.by_user(nil)).to include(v1, v2, v3)
        expect(Vehicle.by_user("")).to include(v1, v2, v3)
      end
    end
  end

  describe ".filter" do
    let!(:u1) { create(:user) }
    let!(:u2) { create(:user) }
    let!(:v1) { create(:vehicle, status: :disponible, license_plate: "AAA111", user: u1) }
    let!(:v2) { create(:vehicle, status: :en_taller, license_plate: "BBB222", user: u1) }
    let!(:v3) { create(:vehicle, status: :disponible, license_plate: "CCC333", user: u2) }

    it "filters by status" do
      result = Vehicle.filter({ status: "disponible" })
      expect(result).to match_array([v1, v3])
    end

    it "filters by user_id" do
      result = Vehicle.filter({ user_id: u1.id })
      expect(result).to match_array([v1, v2])
    end

    it "filters by license_plate" do
      result = Vehicle.filter({ license_plate: "AAA" })
      expect(result).to eq([v1])
    end

    it "combines multiple filters" do
      result = Vehicle.filter({ status: "disponible", user_id: u1.id })
      expect(result).to eq([v1])
    end

    it "applies includes for associations" do
      rel = Vehicle.filter({}, [:user])
      expect(rel.includes_values).to include(:user)
    end

    it "returns all when params empty" do
      expect(Vehicle.filter).to match_array([v1, v2, v3])
    end
  end
end
