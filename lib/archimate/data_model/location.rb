# frozen_string_literal: true

module Archimate
  module DataModel
    # @todo x & y Defined like this in the XSD
    # NonNegativeInteger = Int.constrained(gteq: 0)
    # NonNegativeFloat = Float # .constrained(gteq: 0)

    # Graphical node type. It can contain child node types.
    # This is LocationType/LocationGroup in the XSD.
    class Location
      include Comparison

      # The x (towards the right, associated with width) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      # @note the XSD has this as a NonNegativeInteger
      # @!attribute [r] x
      # @return [Float]
      model_attr :x, writable: true
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      # @note the XSD has this as a NonNegativeInteger
      # @!attribute [r] y
      # @return [Float]
      model_attr :y, writable: true

      def initialize(x:, y:)
        @x = x.to_i
        @y = y.to_i
      end

      def to_s
        "Location(x: #{x}, y: #{y})"
      end

      # Returns true if this location is inside the bounds argument
      # @param bounds [Bounds]
      def inside?(bounds)
        bounds.x_range.cover?(x) &&
          bounds.y_range.cover?(y)
      end
    end
  end
end
