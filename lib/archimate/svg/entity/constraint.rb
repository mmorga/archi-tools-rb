# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Constraint < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-motivation2-background"
          @badge = "#archimate-constraint-badge"
        end
      end
    end
  end
end
