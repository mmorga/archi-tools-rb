# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Location < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-location-badge"
        end
      end
    end
  end
end
