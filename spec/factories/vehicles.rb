FactoryBot.define do
  factory :vehicle do
    license_plate { Faker::Vehicle.license_plate }
    make          { Faker::Vehicle.manufacture }
    model         { Faker::Vehicle.model }
    year          { rand(1900..Date.current.year) }
    status        { :disponible }
    association   :user
  end
end
