# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class ServiceEntity < RoundedRectEntity
        def initialize(child, bounds_offset)
          super
          bounds = child.bounds
          @badge = "#archimate-service-badge"
          @text_bounds = DataModel::Bounds.new(
            x: bounds.left + 7,
            y: bounds.top + 5,
            width: bounds.width - 14,
            height: bounds.height - 10
          )
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when "1"
            service_path(xml, bounds)
            @badge = nil
          else
            super
          end
        end

        def service_path(xml, bounds)
          xml.rect(
            x: bounds.left,
            y: bounds.top,
            width: bounds.width,
            height: bounds.height,
            rx: bounds.height / 2.0,
            ry: bounds.height / 2.0,
            class: background_class,
            style: shape_style
          )
        end
      end
    end
  end
end
