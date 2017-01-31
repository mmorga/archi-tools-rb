# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      # TODO: support alternate appearance
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
          xml.path(
            d: [
              "M", bounds.left, bounds.top + bounds.height * (3.0 / 20),
              "h", bounds.width * (11.0 / 20),
              "v", bounds.height * (-4.0 / 20),
              "l", bounds.width * (7.0 / 20), bounds.height * (6.0 / 20),
              "l", -bounds.width * (7.0 / 20), bounds.height * (6.0 / 20),
              "v", bounds.height * (-4.0 / 20),
              "h", bounds.width * (-11.0 / 20),
              "z"
            ].flatten.join(" "),
            class: background_class,
            style: shape_style
          )
        end
      end
    end
  end
end
