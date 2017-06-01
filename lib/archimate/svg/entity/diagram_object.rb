# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class DiagramObject < BaseEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-note-background"
          @text_align = "left"
        end

        def entity_shape(xml, bounds)
          xml.path(
            d: [
              ["m", bounds.left, bounds.top],
              ["h", bounds.width],
              ["v", bounds.height - 8],
              ["l", -8, 8],
              ["h", -(bounds.width - 8)],
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
