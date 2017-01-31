# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      module NodeShape
        def node_path(xml, bounds)
          margin = 14
          @badge_bounds = DataModel::Bounds.new(
            x: bounds.right - margin - 25,
            y: bounds.top + margin + 5,
            width: 20,
            height: 20
          )
          node_box_height = bounds.height - margin
          node_box_width = bounds.width - margin
          @text_bounds = DataModel::Bounds.new(
            x: bounds.left + 1,
            y: bounds.top + margin + 1,
            width: node_box_width - 2,
            height: node_box_height - 2
          )
          xml.g(class: background_class, style: shape_style) do
            xml.path(
              d: [
                ["M", bounds.left, bounds.bottom],
                ["v", -node_box_height],
                ["l", margin, -margin],
                ["h", node_box_width],
                ["v", node_box_height],
                ["l", -margin, margin],
                "z"
              ].flatten.join(" ")
            )
            xml.path(
              d: [
                ["M", bounds.left, bounds.top + margin],
                ["l", margin, -margin],
                ["h", node_box_width],
                ["v", node_box_height],
                ["l", -margin, margin],
                ["v", -node_box_height],
                "z",
                ["M", bounds.right, bounds.top],
                ["l", -margin, margin]
              ].flatten.join(" "),
              class: "archimate-decoration"
            )
            xml.path(
              d: [
                ["M", bounds.left, bounds.top + margin],
                ["h", node_box_width],
                ["l", margin, -margin],
                ["M", bounds.left + node_box_width, bounds.bottom],
                ["v", -node_box_height]
              ].flatten.join(" "),
              style: "fill:none;stroke:inherit;"
            )
          end
        end
      end
    end
  end
end
