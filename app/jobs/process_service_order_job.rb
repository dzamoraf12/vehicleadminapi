class ProcessServiceOrderJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    # TODO: Implement actual processing logic, validations, and error handling.
    # For now, we will simulate processing by sleeping for 10 seconds
    # and then closing the order and updating the vehicle status.
    # This is a placeholder for the actual processing logic.
    order   = ServiceOrder.find(order_id)
    vehicle = order.vehicle

    sleep 10

    order.update!(status: :cerrada)
    vehicle.update!(status: :disponible)
  end
end
