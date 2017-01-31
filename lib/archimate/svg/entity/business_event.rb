# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class BusinessEvent < BaseEntity
        def entity_shape(xml, bounds)
          event_path(xml, bounds)
        end

        def event_path(xml, bounds)
          notch_x = 18
          notch_height = bounds.height / 2.0
          event_width = bounds.width * 0.85
          rx = 17
          xml.path(
            d: [
              "M", bounds.left, bounds.top,
              "l", notch_x, notch_height,
              "l", -notch_x, notch_height,
              "h", event_width,
              "a", rx, notch_height, 0, 0, 0, 0, -bounds.height,
              "z"
            ].flatten.join(" "),
            class: background_class, style: shape_style
          )
        end
      end
    end
  end
end
