# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Assessment < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-assessment-badge"
        end
      end
    end
  end
end
