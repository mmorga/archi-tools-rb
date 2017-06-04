# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Artifact < BaseEntity
        def initialize(child, bounds_offset)
          super
          @badge = "archimate-artifact-badge"
        end

        def entity_shape(xml, bounds)
          margin = 18
          xml.g(class: background_class, style: shape_style) do
            xml.path(
              d: [
                ["M", bounds.left, bounds.top],
                ["h", bounds.width - margin],
                ["l", margin, margin],
                ["v", bounds.height - margin],
                ["h", -bounds.width],
                "z"
              ].flatten.join(" ")
            )
            xml.path(
              d: [
                ["M", bounds.right - margin, bounds.top],
                ["v", margin],
                ["h", margin],
                "z"
              ].flatten.join(" "),
              class: "archimate-decoration"
            )
          end
        end
      end
    end
  end
end
