module Archimate
  module Model
    class Bounds < Dry::Struct::Value
      attribute :x, Archimate::Types::Maybe::Coercible::Float
      attribute :y, Archimate::Types::Maybe::Coercible::Float
      attribute :width, Archimate::Types::Maybe::Coercible::Float
      attribute :height, Archimate::Types::Maybe::Coercible::Float
    end
  end
end
