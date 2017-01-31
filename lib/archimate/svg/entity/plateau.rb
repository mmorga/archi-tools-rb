# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class Plateau < Node
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-implementation2-background"
          @badge = "#archimate-plateau-badge"
        end
      end
    end
  end
end
