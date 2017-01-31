# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      # TODO: support alternate appearance
      class ServiceEntity < BaseEntity
        include Service
        include Rect

        def initialize(child, bounds_offset)
          super
          bounds = child.bounds
          @text_bounds = bounds.with(
            x: bounds.left + 7,
            y: bounds.top + 5,
            width: bounds.width - 14,
            height: bounds.height - 10
          )
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when 1
            @badge_bounds = bounds.with(
              x: bounds.right - 25,
              y: bounds.top + 5,
              width: 20,
              height: 20
            )
            @badge = "#archimate-service-badge"
            rect_path(xml, bounds)
          else
            service_path(xml, bounds)
          end
        end
      end
    end
  end
end
