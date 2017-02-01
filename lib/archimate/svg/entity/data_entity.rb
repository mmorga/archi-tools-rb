# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class DataEntity < BaseEntity
        def initialize(child, bounds_offset)
          super
          @margin = 10
        end

        def calc_text_bounds(_bounds)
          @text_bounds = @text_bounds.with(
            y: @text_bounds.top + @margin,
            height: @text_bounds.height - @margin
          )
        end

        def entity_shape(xml, bounds)
          calc_text_bounds(bounds)
          xml.g(class: background_class) do
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: background_class, style: shape_style)
            xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: @margin, class: "archimate-decoration")
          end
        end
      end
    end
  end
end
