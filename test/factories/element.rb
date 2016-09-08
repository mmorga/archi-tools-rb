# This will guess the User class
FactoryGirl.define do
  factory :element, class: Archimate::Model::Element do
    identifier { Faker::Number.hexadecimal(8) }
    type { random_element_type }
    label { Faker::Company.buzzword }
    documentation { [] }
    properties { [] }
  end
end
