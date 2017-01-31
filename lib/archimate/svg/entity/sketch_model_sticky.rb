# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class SketchModelSticky < RectEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-sticky-background"
        end
      end
    end
  end
end
