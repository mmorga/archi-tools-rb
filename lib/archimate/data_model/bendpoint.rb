module Archimate
  module DataModel
    class Bendpoint < Dry::Struct::Value
      attribute :start_x, Dry::Types['coercible.float'].optional # Coercible::Float.optional
      attribute :start_y, Dry::Types['coercible.float'].optional # Coercible::Float.optional
      attribute :end_x, Dry::Types['coercible.float'].optional # Coercible::Float.optional
      attribute :end_y, Dry::Types['coercible.float'].optional # Coercible::Float.optional
    end

    Dry::Types.register_class(Bendpoint)
    BendpointList = Strict::Array.member(Bendpoint)
  end
end
