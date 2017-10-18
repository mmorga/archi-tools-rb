
# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Node < BaseEntity
        include Rect
        include NodeShape

        def initialize(child, bounds_offset)
          super
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when 1
            @badge_bounds = DataModel::Bounds.new(
              x: bounds.right - 25,
              y: bounds.top + 5,
              width: 20,
              height: 20
            )
            @badge = "#archimate-node-badge"
            rect_path(xml, bounds)
          else
            node_path(xml, bounds)
          end
        end
      end
    end
  end
end
