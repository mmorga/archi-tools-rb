# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class SystemSoftware < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-system-software-badge"
        end
      end
    end
  end
end
