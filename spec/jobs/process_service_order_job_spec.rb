require "rails_helper"

RSpec.describe ProcessServiceOrderJob, type: :job do
  include ActiveJob::TestHelper

  let(:user_admin) { create(:user, role: :admin) }
  let(:user_driver) { create(:user, role: :chofer) }
  let(:vehicle) { create(:vehicle, status: :en_taller, user: user_admin) }
  let!(:report) { create(:maintenance_report, status: :pendiente, priority: :alta,
                                               vehicle: vehicle, user: user_driver) }
  let(:order) { create(:service_order, vehicle: vehicle, status: :abierta,
                                       maintenance_report: report) }

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  it "closes the order and sets vehicle back to disponible" do
    allow_any_instance_of(ProcessServiceOrderJob).to receive(:sleep).with(10)

    described_class.perform_now(order.id)

    expect(order.reload.status).to eq("cerrada")
    expect(vehicle.reload.status).to eq("disponible")
  end

  it "is enqueued on the default queue" do
    expect {
      described_class.perform_later(order.id)
    }.to have_enqueued_job.on_queue("default").with(order.id)
  end
end
