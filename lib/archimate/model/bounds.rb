module Archimate
  module Model
    class Bounds < Dry::Struct::Value
      attribute :x, Types::Coercible::Float.optional
      attribute :y, Types::Coercible::Float.optional
      attribute :width, Types::Coercible::Float
      attribute :height, Types::Coercible::Float
    end
  end
end
