# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class BusinessActor < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-actor-badge"
        end
      end
    end
  end
end
