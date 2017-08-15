# frozen_string_literal: true

module Archimate
  module DataModel
    # TODO: x & y Defined like this in the XSD
    # NonNegativeInteger = Coercible::Int.constrained(gteq: 0)
    # NonNegativeFloat = Coercible::Float # .constrained(gteq: 0)

    # Graphical node type. It can contain child node types.
    # This is LocationType/LocationGroup in the XSD.
    class Location
      include Comparison

      # The x (towards the right, associated with width) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      model_attr :x # NonNegativeFloat # Note the XSD has this as an Int, NonNegativeInteger
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      model_attr :y # NonNegativeFloat # Note the XSD has this as an Int, NonNegativeInteger

      # These are holdovers from the archi file format and are only maintained for compatability
      model_attr :end_x # Coercible::Int.optional.default(nil)
      model_attr :end_y # Coercible::Int.optional.default(nil)

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
