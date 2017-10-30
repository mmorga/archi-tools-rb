# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class Location < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-location-badge"
          @background_class = "archimate-location-background"
        end
      end
    end
  end
end
