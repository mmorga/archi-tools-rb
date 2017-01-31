# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class InterfaceEntity < RectEntity
        include Circle

        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-interface-badge"
        end

        def entity_shape(xml, bounds)
          case child.child_type
          when 1
            @badge = nil
            circle_path(xml, bounds)
          else
            super
          end
        end
      end
    end
  end
end
