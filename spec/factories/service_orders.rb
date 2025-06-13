FactoryBot.define do
  factory :service_order do
    estimated_cost { "1999" }
    status { "abierta" }
    maintenance_report { nil }
    vehicle { nil }
  end
end
