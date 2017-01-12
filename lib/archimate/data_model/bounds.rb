# frozen_string_literal: true
module Archimate
  module DataModel
    class Bounds < ArchimateNode
      attribute :x, Coercible::Float.optional
      attribute :y, Coercible::Float.optional
      attribute :width, Coercible::Float
      attribute :height, Coercible::Float

      def self.zero
        Archimate::DataModel::Bounds.new(x: 0, y: 0, width: 0, height: 0)
      end

      def to_s
        "Bounds(x: #{x}, y: #{y}, width: #{width}, height: #{height})"
      end
    end

    Dry::Types.register_class(Bounds)
  end
end
