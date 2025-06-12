FactoryBot.define do
  factory :maintenance_report do
    description { "MyText" }
    priority { 1 }
    status { 1 }
    reported_at { "2025-06-12 23:26:10" }
    vehicle { nil }
    user { nil }
  end
end
