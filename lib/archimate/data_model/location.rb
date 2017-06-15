# frozen_string_literal: true

module Archimate
  module DataModel
    # TODO: x & y Defined like this in the XSD
    NonNegativeInteger = Coercible::Int.constrained(gteq: 0)
    NonNegativeFloat = Coercible::Float # .constrained(gteq: 0)

    # Graphical node type. It can contain child node types.
    # This is LocationType/LocationGroup in the XSD.
    class Location < ArchimateNode
      # The x (towards the right, associated with width) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      attribute :x, NonNegativeFloat # Note the XSD has this as an Int, NonNegativeInteger
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      attribute :y, NonNegativeFloat # Note the XSD has this as an Int, NonNegativeInteger

      # These are holdovers from the archi file format and are only maintained for compatability
      attribute :end_x, Coercible::Int.optional
      attribute :end_y, Coercible::Int.optional

      def to_s
        "Location(x: #{x}, y: #{y})"
      end
    end

    Dry::Types.register_class(Location)
    LocationList = Strict::Array.member(Location).default([])
  end
end
