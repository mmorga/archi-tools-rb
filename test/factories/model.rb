# Defines a factory for the Model class
FactoryGirl.define do
  factory :model, class: Archimate::Model::Model do
    id { Faker::Number.hexadecimal(8) }
    name { Faker::Company.name }
    documentation { [] }
    properties { [] }
    elements {}
    organization {}
    relationships {}
  end
end
