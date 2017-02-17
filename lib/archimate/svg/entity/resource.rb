# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Resource < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-resource-badge"
        end
      end
    end
  end
end
