require "rails_helper"

RSpec.describe CreateServiceOrderAndSchedule, type: :service do
  include ActiveJob::TestHelper

  let(:user_admin) { create(:user, role: :admin) }
  let(:user_driver) { create(:user, role: :chofer) }
  let(:vehicle) { create(:vehicle, status: :disponible, user: user_admin) }
  let!(:report) { create(:maintenance_report, status: :pendiente, priority: :alta,
                                              vehicle: vehicle, user: user_driver) }

  subject(:service) { described_class.new(report) }

  before do
    ActiveJob::Base.queue_adapter = :test
    clear_enqueued_jobs
  end

  describe "#call" do
    it "updates vehicle status to en_taller" do
      service.call
      expect(vehicle.reload.status).to eq("en_taller")
    end

    it "creates a ServiceOrder in status abierta" do
      order = service.call
      expect(order).to be_persisted
      expect(order.status).to eq("abierta")
      expect(order.estimated_cost).to be_between(1000, 5000)
      expect(order.vehicle).to eq(vehicle)
      expect(order.maintenance_report).to eq(report)
    end

    it "enqueues ProcessServiceOrderJob with the new order id" do
      expect {
        service.call
      }.to have_enqueued_job(ProcessServiceOrderJob).with(kind_of(Integer))
    end

    it "returns the created order" do
      order = service.call
      expect(order).to be_a(ServiceOrder)
    end
  end
end
