FactoryBot.define do
  factory :maintenance_report do
    description { Faker::Lorem.paragraph }
    priority { MaintenanceReport.priorities.keys.sample }
    status { MaintenanceReport.statuses.keys.sample }
    reported_at { Faker::Date.between(from: 5.days.ago, to: Date.today - 1.day) }
    vehicle { nil }
    user { nil }
  end
end
