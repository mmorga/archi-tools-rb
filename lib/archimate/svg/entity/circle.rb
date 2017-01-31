# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      module Circle
        def circle_path(xml, bounds)
          xml.circle(cx: bounds.left + bounds.width / 2.0, cy: bounds.top + bounds.height / 2.0, r: bounds.width / 2.0, class: background_class, style: shape_style)
        end
      end
    end
  end
end
