# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Gap < Representation
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-implementation2-background"
          @badge = "#archimate-gap-badge"
          @badge_bounds = child.bounds.with(
            x: child.bounds.right - 25,
            y: child.bounds.top + 5,
            width: 20,
            height: 20
          )
        end
      end
    end
  end
end
