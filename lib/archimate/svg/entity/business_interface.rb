# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      # TODO: support alternate appearance
      class BusinessInterface < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-interface-badge"
        end
      end
    end
  end
end
