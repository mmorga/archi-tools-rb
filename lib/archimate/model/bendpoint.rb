module Archimate
  module Model
    class Bendpoint < Dry::Struct::Value
      attribute :start_x, Archimate::Types::Maybe::Coercible::Float
      attribute :start_y, Archimate::Types::Maybe::Coercible::Float
      attribute :end_x, Archimate::Types::Maybe::Coercible::Float
      attribute :end_y, Archimate::Types::Maybe::Coercible::Float
    end
  end
end
