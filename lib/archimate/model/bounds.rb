module Archimate
  module Model
    class Bounds < Dry::Struct::Value
      attribute :x, Archimate::Types::Coercible::Float.optional
      attribute :y, Archimate::Types::Coercible::Float.optional
      attribute :width, Archimate::Types::Coercible::Float
      attribute :height, Archimate::Types::Coercible::Float
    end
  end
end
