# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Product < BaseEntity
        def entity_shape(xml, bounds)
          product_path(xml, bounds)
        end

        def product_path(xml, bounds)
          xml.g(class: background_class) do
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: background_class, style: shape_style)
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: "8", class: "archimate-decoration")
          end
        end
      end
    end
  end
end
