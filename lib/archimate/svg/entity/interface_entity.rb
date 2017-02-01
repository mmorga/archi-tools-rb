# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class InterfaceEntity < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-interface-badge"
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when 1
            @badge = nil
            elipse_path(xml, bounds)
          else
            super
          end
        end

        def elipse_path(xml, bounds)
          xml.ellipse(
            cx: bounds.left + bounds.width / 2.0,
            cy: bounds.top + bounds.height / 2.0,
            rx: bounds.width / 2.0,
            ry: bounds.height / 2.0,
            class: background_class,
            style: shape_style
          )
        end
      end
    end
  end
end
