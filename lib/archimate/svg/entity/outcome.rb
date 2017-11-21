# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Outcome < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-outcome-badge"
        end
      end
    end
  end
end
