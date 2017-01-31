
# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      module Service
        def service_path(xml, bounds)
          xml.rect(
            x: bounds.left,
            y: bounds.top,
            width: bounds.width,
            height: bounds.height,
            rx: bounds.height / 2.0,
            ry: bounds.height / 2.0,
            class: background_class,
            style: shape_style
          )
        end
      end
    end
  end
end
