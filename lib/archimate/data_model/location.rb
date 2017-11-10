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
      model_attr :x
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      # @note the XSD has this as a NonNegativeInteger
      # @!attribute [r] y
      # @return [Float]
      model_attr :y

      # These are holdovers from the archi file format and are only maintained for compatability
      # @!attribute [r] end_x
      # @return [Int, NilClass]
      model_attr :end_x, default: nil
      # @!attribute [r] end_y
      # @return [Int, NilClass]
      model_attr :end_y, default: nil

      def initialize(x:, y:, end_x: nil, end_y: nil)
        @x = x.to_i
        @y = y.to_i
        @end_x = end_x.nil? ? nil : end_x.to_i
        @end_y = end_y.nil? ? nil : end_y.to_i
      end

      def to_s
        "Location(x: #{x}, y: #{y})"
      end
    end
  end
end
