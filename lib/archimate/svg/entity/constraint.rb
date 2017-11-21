# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Constraint < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-constraint-badge"
        end
      end
    end
  end
end
