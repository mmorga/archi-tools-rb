# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Driver < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-driver-badge"
        end
      end
    end
  end
end
