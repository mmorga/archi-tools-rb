
# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Junction < RectEntity
        include Circle

        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-junction-background"
        end

        def entity_shape(xml, bounds)
          circle_path(xml, bounds)
        end
      end
    end
  end
end
