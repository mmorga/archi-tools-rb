# frozen_string_literal: true
module Archimate
  module DataModel
    class Bendpoint < Dry::Struct::Value
      attribute :start_x, Coercible::Float.optional
      attribute :start_y, Coercible::Float.optional
      attribute :end_x, Coercible::Float.optional
      attribute :end_y, Coercible::Float.optional
    end

    Dry::Types.register_class(Bendpoint)
    BendpointList = Strict::Array.member(Bendpoint)
  end
end
