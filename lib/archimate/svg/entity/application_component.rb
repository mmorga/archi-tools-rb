# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      # TODO: support alternate appearance
      class ApplicationComponent < BaseEntity
        def initialize(child, bounds_offset)
          super
        end

        def entity_shape(xml, bounds)
          component_path(xml, bounds)
        end

        def component_path(xml, bounds)
          main_box_x = bounds.left + 21.0 / 2
          main_box_width = bounds.width - 21 / 2
          set_text_bounds(bounds, main_box_x)
          xml.rect(x: main_box_x, y: bounds.top, width: main_box_width, height: bounds.height, class: background_class, style: shape_style)
          component_decoration(xml, bounds.left, bounds.top + 10)
          component_decoration(xml, bounds.left, bounds.top + 30)
        end

        def component_decoration(xml, left, top)
          xml.rect(x: left, y: top, width: "21", height: "13", class: background_class, style: shape_style)
          xml.rect(x: left, y: top, width: "21", height: "13", class: "archimate-decoration")
        end

        def set_text_bounds(bounds, main_box_x)
          @text_bounds = DataModel::Bounds.new(
            x: main_box_x + 21 / 2,
            y: bounds.top + 1,
            width: bounds.width - 22,
            height: bounds.height - 2
          )
        end
      end
    end
  end
end
