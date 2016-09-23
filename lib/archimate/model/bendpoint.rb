module Archimate
  module Model
    class Bendpoint < Dry::Struct::Value
      attribute :start_x, Archimate::Types::Coercible::Float.optional
      attribute :start_y, Archimate::Types::Coercible::Float.optional
      attribute :end_x, Archimate::Types::Coercible::Float.optional
      attribute :end_y, Archimate::Types::Coercible::Float.optional
    end
  end
end
