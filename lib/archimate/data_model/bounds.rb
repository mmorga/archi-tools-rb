# frozen_string_literal: true
module Archimate
  module DataModel
    class Bounds < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :x, Coercible::Float.optional
      attribute :y, Coercible::Float.optional
      attribute :width, Coercible::Float
      attribute :height, Coercible::Float

      def comparison_attributes
        [:@x, :@y, :@width, :@height]
      end

      def to_s
        "Bounds(x: #{x}, y: #{y}, width: #{width}, height: #{height})"
      end
    end

    Dry::Types.register_class(Bounds)
    OptionalBounds = Bounds.optional
  end
end
