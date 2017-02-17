# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Outcome < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-motivation2-background"
          @badge = "#archimate-outcome-badge"
        end
      end
    end
  end
end
