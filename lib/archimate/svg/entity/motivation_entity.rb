# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class MotivationEntity < BaseEntity
        def initialize(child, bounds_offset)
          super
          @badge_bounds = DataModel::Bounds.new(
            x: child.bounds.right - 25,
            y: child.bounds.top + 5,
            width: 20,
            height: 20
          )
        end

        def entity_shape(xml, bounds)
          margin = 10
          width = bounds.width - margin * 2
          height = bounds.height - margin * 2
          xml.path(
            d: [
              ["M", bounds.left + margin, bounds.top],
              ["h", width],
              ["l", margin, margin],
              ["v", height],
              ["l", -margin, margin],
              ["h", -width],
              ["l", -margin, -margin],
              ["v", -height],
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
