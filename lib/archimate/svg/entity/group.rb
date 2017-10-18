
# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Group < BaseEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-group-background"
        end

        def entity_shape(xml, bounds)
          group_header_height = 21
          xml.rect(x: bounds.left, y: bounds.top + group_header_height, width: bounds.width, height: bounds.height - group_header_height, class: background_class, style: shape_style)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: group_header_height, class: background_class, style: shape_style)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: group_header_height, class: "archimate-decoration")
          @text_bounds = DataModel::Bounds.new(bounds.to_h.merge(height: group_header_height))
          @text_align = "left"
        end
      end
    end
  end
end
