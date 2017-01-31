# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class InteractionEntity < RoundedRectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-interaction-badge"
        end
      end
    end
  end
end
