# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Facility < BaseEntity
        include NodeShape

        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-facility-badge"
        end
      end
    end
  end
end
