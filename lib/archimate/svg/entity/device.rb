# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Device < BaseEntity
        include NodeShape

        def initialize(child, bounds_offset)
          super
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when 1
            @badge = "#archimate-device-badge"
            node_path(xml, bounds)
          else
            device_path(xml, bounds)
          end
        end

        def device_path(xml, bounds)
          margin = 10
          xml.rect(
            x: bounds.left,
            y: bounds.top,
            width: bounds.width,
            height: bounds.height - margin,
            rx: "6",
            ry: "6",
            class: background_class,
            style: shape_style
          )
          decoration_path = [
            "M", bounds.left + margin, bounds.bottom - margin,
            "l", -margin, margin,
            "h", bounds.width,
            "l", -margin, -margin,
            "z"
          ].flatten.join(" ")
          xml.path(d: decoration_path, class: background_class, style: shape_style)
          xml.path(d: decoration_path, class: "archimate-decoration", style: shape_style)
        end
      end
    end
  end
end
