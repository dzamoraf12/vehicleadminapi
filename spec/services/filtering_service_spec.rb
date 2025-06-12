require "rails_helper"

RSpec.describe FilteringService, type: :service do
  let!(:user_a) { create(:user) }
  let!(:user_b) { create(:user) }
  let!(:vehicle_available_user_a) { create(:vehicle, status: :disponible, user: user_a) }
  let!(:vehicle_in_workshop_user_a) { create(:vehicle, status: :en_taller, user: user_a) }
  let!(:vehicle_available_user_b) { create(:vehicle, status: :disponible, user: user_b) }

  describe "#filter" do
    context "without any filters" do
      it "returns all records" do
        service = FilteringService.new(Vehicle.all, {})
        expect(service.filter).to match_array([
          vehicle_available_user_a,
          vehicle_in_workshop_user_a,
          vehicle_available_user_b
        ])
      end
    end

    context "filter by status" do
      it "returns only vehicles with the given status" do
        service = FilteringService.new(Vehicle.all, { by_status: "disponible" })
        expect(service.filter).to match_array([
          vehicle_available_user_a,
          vehicle_available_user_b
        ])
      end
    end

    context "filter by user" do
      it "returns only vehicles belonging to the specified user" do
        service = FilteringService.new(Vehicle.all, { by_user: user_a.id })
        expect(service.filter).to match_array([
          vehicle_available_user_a,
          vehicle_in_workshop_user_a
        ])
      end
    end

    context "multiple filters" do
      it "applies multiple filters in sequence" do
        service = FilteringService.new(
          Vehicle.all,
          { by_status: "disponible", by_user: user_a.id }
        )
        expect(service.filter).to eq([vehicle_available_user_a])
      end
    end

    context "blank filter values" do
      it "ignores filters with blank values" do
        service = FilteringService.new(
          Vehicle.all,
          { by_status: "disponible", by_user: "" }
        )
        expect(service.filter).to match_array([
          vehicle_available_user_a,
          vehicle_available_user_b
        ])
      end
    end

    context "association inclusion" do
      it "applies .includes(...) when associations are provided" do
        service = FilteringService.new(Vehicle.all, {}, [:user])
        result  = service.filter
        expect(result.includes_values).to include(:user)
      end

      it "does not include associations if none are given" do
        service = FilteringService.new(Vehicle.all, {}, [])
        expect(service.filter.includes_values).to be_empty
      end
    end

    context "when an invalid filter key is provided" do
      it "raises a NoMethodError for unknown scope" do
        service = FilteringService.new(Vehicle.all, { unknown_scope: "x" })
        expect { service.filter }.to raise_error(NoMethodError)
      end
    end
  end
end
