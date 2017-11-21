# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Requirement < MotivationEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-requirement-badge"
        end
      end
    end
  end
end
