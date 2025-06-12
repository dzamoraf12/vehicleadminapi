require "rails_helper"

RSpec.describe VehicleBlueprint, type: :blueprint do
  let(:vehicle_attributes) { attributes_for(:vehicle, id: 1000) }
  let(:vehicle) do
    build(
      :vehicle,
      id:            vehicle_attributes[:id],
      license_plate: vehicle_attributes[:license_plate],
      make:          vehicle_attributes[:make],
      model:         vehicle_attributes[:model],
      year:          vehicle_attributes[:year],
      status:        vehicle_attributes[:status]
    )
  end

  describe ".render_as_hash" do
    subject(:hash) { VehicleBlueprint.render_as_hash(vehicle) }

    it "includes the identifier :id" do
      expect(hash).to include(id: 1000)
    end

    it "includes the license_plate field" do
      expect(hash).to include(license_plate: vehicle_attributes[:license_plate])
    end

    it "includes the make field" do
      expect(hash).to include(make: vehicle_attributes[:make])
    end

    it "includes the model field" do
      expect(hash).to include(model: vehicle_attributes[:model])
    end

    it "includes the year field" do
      expect(hash).to include(year: vehicle_attributes[:year])
    end

    it "includes the status field" do
      expect(hash).to include(status: vehicle_attributes[:status].to_s)
    end

    it "does not include unexpected attributes" do
      allowed_keys = [ :id, :license_plate, :make, :model, :year, :status ]
      expect(hash.keys).to match_array(allowed_keys)
    end
  end

  describe ".render_as_hash on a collection" do
    let(:vehicle2_attributes) { attributes_for(:vehicle, id: 1001) }
    let(:vehicle2) do
      build(
        :vehicle,
        id:            vehicle2_attributes[:id],
        license_plate: vehicle2_attributes[:license_plate],
        make:          vehicle2_attributes[:make],
        model:         vehicle2_attributes[:model],
        year:          vehicle2_attributes[:year],
        status:        vehicle2_attributes[:status]
      )
    end

    subject(:array) { VehicleBlueprint.render_as_hash([vehicle, vehicle2]) }

    it "returns an array of hashes" do
      expect(array).to be_an(Array)
      expect(array.size).to eq(2)
    end

    it "serializes each element correctly" do
      expect(array[0]).to include(id: vehicle_attributes[:id], license_plate: vehicle_attributes[:license_plate],
                                  make: vehicle_attributes[:make], model: vehicle_attributes[:model],
                                  year: vehicle_attributes[:year], status: vehicle_attributes[:status].to_s)
      expect(array[1]).to include(id: vehicle2_attributes[:id], license_plate: vehicle2_attributes[:license_plate],
                                  make: vehicle2_attributes[:make], model: vehicle2_attributes[:model],
                                  year: vehicle2_attributes[:year], status: vehicle2_attributes[:status].to_s)
    end
  end
end
