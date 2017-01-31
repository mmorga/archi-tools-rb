# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class RoundedRectEntity < BaseEntity
        include RoundedRect

        def initialize(child, bounds_offset)
          super
          @badge_bounds = child.bounds.with(
            x: child.bounds.right - 25,
            y: child.bounds.top + 5,
            width: 20,
            height: 20
          )
        end

        def entity_shape(xml, bounds)
          rounded_rect_path(xml, bounds)
        end
      end
    end
  end
end
