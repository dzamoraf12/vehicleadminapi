FactoryBot.define do
  factory :service_order do
    estimated_cost { "9.99" }
    status { 1 }
    maintenance_report { nil }
  end
end
