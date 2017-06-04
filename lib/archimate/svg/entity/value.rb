# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Value < BaseEntity
        def entity_shape(xml, bounds)
          calc_text_bounds(bounds)
          cx = bounds.left + bounds.width / 2.0
          rx = bounds.width / 2.0 - 1
          cy = bounds.top + bounds.height / 2.0
          ry = bounds.height / 2.0 - 1
          xml.ellipse(cx: cx, cy: cy, rx: rx, ry: ry, class: background_class, style: shape_style)
        end

        def calc_text_bounds(_bounds)
          @text_bounds = @text_bounds.with(
            x: @text_bounds.left + 10,
            y: @text_bounds.top + 10,
            width: @text_bounds.width - 20,
            height: @text_bounds.height - 20
          )
        end
      end
    end
  end
end
