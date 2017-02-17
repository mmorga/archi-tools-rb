# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Material < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-material-badge"
        end
      end
    end
  end
end
