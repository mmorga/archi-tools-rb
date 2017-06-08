# frozen_string_literal: true

module Archimate
  module DataModel
    PositiveInteger = Strict::Int.constrained(gt: 0)

    # Graphical node type. It can contain child node types.
    class ViewNode < ViewConcept
      # LocationGroup: TODO: Consider making this a mixin or extract object
      # The x (towards the right, associated with width) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      attribute :x, NonNegativeInteger
      # The y (towards the bottom, associated with height) attribute from the Top,Left (i.e. 0,0)
      # corner of the diagram to the Top, Left corner of the bounding box of the concept.
      attribute :y, NonNegativeInteger

      # SizeGroup:
      # The width (associated with x) attribute from the Left side to the right side of the
      # bounding box of a concept.
      attribute :w, PositiveInteger
      # The height (associated with y) attribute from the top side to the bottom side of the
      # bounding box of a concept.
      attribute :h, PositiveInteger
    end

    Dry::Types.register_class(ViewNode)
  end
end
