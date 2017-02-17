# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Equipment < BaseEntity
        include NodeShape

        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-equipment-badge"
        end
      end
    end
  end
end
