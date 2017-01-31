# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      module RoundedRect
        def rounded_rect_path(xml, bounds)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, rx: "5", ry: "5", class: background_class)
        end
      end
    end
  end
end
