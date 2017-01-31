# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class FunctionEntity < RoundedRectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-function-badge"
        end
      end
    end
  end
end
