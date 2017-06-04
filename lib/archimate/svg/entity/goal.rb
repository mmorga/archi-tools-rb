# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Goal < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-goal-badge"
        end
      end
    end
  end
end
