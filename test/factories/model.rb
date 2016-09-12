# Defines a factory for the Model class
FactoryGirl.define do
  factory :model, class: Archimate::Model::Model do
    id { Faker::Number.hexadecimal(8) }
    name { Faker::Company.name }
    documentation { [] }
    properties { [] }
    elements { Hash.new }
    organization { Hash.new }
    relationships { Hash.new }

    trait :with_elements do
      elements { Archimate.array_to_id_hash(build_list(:element, 3)) }
    end
  end
end
