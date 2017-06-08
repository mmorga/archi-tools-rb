# frozen_string_literal: true

module Archimate
  module DataModel
    NonNegativeInteger = Strict::Int.constrained(gteq: 0)

    # Graphical node type. It can contain child node types.
    class Location < ViewConcept
      # The x (towards the right, associated with width) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      attribute :x, NonNegativeInteger
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      attribute :y, NonNegativeInteger
    end

    Dry::Types.register_class(Location)
  end
end
