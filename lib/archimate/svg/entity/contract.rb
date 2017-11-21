# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Contract < DataEntity
        def initialize(child, bounds_offset)
          super
        end

        def entity_shape(xml, bounds)
          calc_text_bounds(bounds)
          xml.g(class: background_class) do
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: background_class, style: shape_style)
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: @margin, class: "archimate-decoration")
            xml.rect(x: bounds.left, y: bounds.top + bounds.height - @margin, width: bounds.width, height: @margin, class: "archimate-decoration")
          end
        end
      end
    end
  end
end
