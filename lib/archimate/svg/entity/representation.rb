# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Representation < BaseEntity
        def entity_shape(xml, bounds)
          representation_path(xml, bounds)
        end

        def representation_path(xml, bounds)
          xml.path(
            d: [
              ["M", bounds.left, bounds.top],
              ["v", bounds.height - 8],
              ["c", 0.167 * bounds.width, 0.133 * bounds.height,
               0.336 * bounds.width, 0.133 * bounds.height,
               bounds.width * 0.508, 0],
              ["c", 0.0161 * bounds.width, -0.0778 * bounds.height,
               0.322 * bounds.width, -0.0778 * bounds.height,
               bounds.width * 0.475, 0],
              ["v", -(bounds.height - 8)],
              "z"
            ].flatten.join(" "),
            class: background_class, style: shape_style
          )
        end
      end
    end
  end
end
