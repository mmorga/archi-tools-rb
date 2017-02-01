# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class BusinessProcess < RoundedRectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-process-badge"
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when 1
            @badge = nil
            process_path(xml, bounds)
          else
            super
          end
        end

        def process_path(xml, bounds)
          top = bounds.top
          shaft_top = bounds.top + bounds.height * 0.15
          middle = bounds.top + bounds.height * 0.5
          shaft_bottom = bounds.bottom - bounds.height * 0.15
          bottom = bounds.bottom

          left = bounds.left
          arrow_back = bounds.right - bounds.height * 0.5
          right = bounds.right

          calc_text_bounds(
            DataModel::Bounds.new(
              x: left,
              y: shaft_top,
              width: bounds.width - bounds.height * 0.25,
              height: shaft_bottom - shaft_top
            )
          )
          xml.path(
            d: [
              "M", left, shaft_top,
              "L", arrow_back, shaft_top,
              "L", arrow_back, top,
              "L", right, middle,
              "L", arrow_back, bottom,
              "L", arrow_back, shaft_bottom,
              "L", left, shaft_bottom,
              "z"
            ].flatten.join(" "),
            class: background_class,
            style: shape_style
          )
        end

        def calc_text_bounds(bounds)
          @text_bounds = bounds.reduced_by(2)
        end
      end
    end
  end
end
