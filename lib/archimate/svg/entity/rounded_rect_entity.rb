# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class RoundedRectEntity < BaseEntity
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
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, rx: "5", ry: "5", class: background_class)
        end
      end
    end
  end
end
