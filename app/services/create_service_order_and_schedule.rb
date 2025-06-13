class CreateServiceOrderAndSchedule
  def initialize(report)
    @report  = report
    @vehicle = report.vehicle
  end

  def call
    @vehicle.update!(status: :en_taller)

    order = ServiceOrder.create!(
      vehicle:            @vehicle,
      maintenance_report: @report,
      status:             :abierta,
      estimated_cost:     rand(1000..5000) # TODO: Replace with actual cost calculation logic
    )

    ProcessServiceOrderJob.perform_later(order.id)

    order
  end
end
