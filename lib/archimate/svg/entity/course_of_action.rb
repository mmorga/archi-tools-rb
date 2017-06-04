# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class CourseOfAction < RoundedRectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-course-of-action-badge"
        end
      end
    end
  end
end
