# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class DistributionNetwork < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-distribution-network-badge"
        end
      end
    end
  end
end
