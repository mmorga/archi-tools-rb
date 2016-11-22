# frozen_string_literal: true
module Archimate
  module DataModel
    class Color < Dry::Struct
      include DataModel::With

      attribute :parent_id, Strict::String
      attribute :r, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :g, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :b, Coercible::Int.constrained(lt: 256, gt: -1)
      attribute :a, Coercible::Int.constrained(lt: 101, gt: -1)

      def comparison_attributes
        [:@r, :@g, :@b, :@a]
      end

      def to_s
        "Color(r: #{r}, g: #{g}, b: #{b}, a: #{a})"
      end

      def to_rgba
        a == 100 ? format("#%02x%02x%02x", r, g, b) : format("#%02x%02x%02x%02x", r, g, b, scaled_alpha)
      end

      private

      def scaled_alpha(max = 255)
        (max * (a / 100.0)).round
      end
    end

    Dry::Types.register_class(Color)
    OptionalColor = Color.optional

    # TODO: create functions to format and convert
  end
end
