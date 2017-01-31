# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Value < BaseEntity
        def entity_shape(xml, bounds)
          value_path(xml, bounds)
        end

        def value_path(xml, bounds)
          cx = bounds.left + bounds.width / 2.0
          rx = bounds.width / 2.0 - 1
          cy = bounds.top + bounds.height / 2.0
          ry = bounds.height / 2.0 - 1
          xml.ellipse(cx: cx, cy: cy, rx: rx, ry: ry, class: background_class, style: shape_style)
        end
      end
    end
  end
end
