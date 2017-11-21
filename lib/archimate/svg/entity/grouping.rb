
# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Grouping < BaseEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-grouping-background"
        end

        def entity_shape(xml, bounds)
          group_header_height = 21
          xml.rect(
            x: bounds.left,
            y: bounds.top + group_header_height,
            width: bounds.width,
            height: bounds.height - group_header_height,
            class: background_class,
            style: shape_style
          )
          xml.path(
            d: ["M", bounds.left, bounds.top + group_header_height - 1,
                "v", -(group_header_height - 1),
                "h", bounds.width / 2,
                "v", group_header_height - 1].map(&:to_s).join(" "),
            class: background_class,
            style: shape_style
          )
          @text_bounds = DataModel::Bounds.new(bounds.to_h.merge(height: group_header_height))
          @text_align = "left"
        end
      end
    end
  end
end
