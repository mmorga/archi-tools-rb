# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      module Data
        def data_path(xml, bounds)
          xml.g(class: background_class) do
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: background_class, style: shape_style)
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: "8", class: "archimate-decoration")
          end
        end
      end
    end
  end
end
