# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      module Rect
        def rect_path(xml, bounds)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: background_class, style: shape_style)
        end
      end
    end
  end
end
