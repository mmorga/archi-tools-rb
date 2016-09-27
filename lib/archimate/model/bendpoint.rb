module Archimate
  module Model
    class Bendpoint < Dry::Struct::Value
      attribute :start_x, Types::Coercible::Float.optional
      attribute :start_y, Types::Coercible::Float.optional
      attribute :end_x, Types::Coercible::Float.optional
      attribute :end_y, Types::Coercible::Float.optional
    end
  end
end
