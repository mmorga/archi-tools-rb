# frozen_string_literal: true
module Archimate
  module DataModel
    class Color < Dry::Struct::Value
      attribute :r, Coercible::Int.optional # TODO: make 0-255 constraint
      attribute :g, Coercible::Int.optional # TODO: make 0-255 constraint
      attribute :b, Coercible::Int.optional # TODO: make 0-255 constraint
      attribute :a, Coercible::Int.optional # TODO: make 0-100 constraint
    end

    Dry::Types.register_class(Color)
    OptionalColor = Color.optional

    # TODO: create functions to format and convert
  end
end
