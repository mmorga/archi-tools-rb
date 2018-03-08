# frozen_string_literal: true

module Archimate
  module Svg
    module Entity
      class AndJunction < RectEntity
        def initialize(child, bounds_offset)
          super
          @background_class = "archimate-junction-background"
        end

        def entity_label(_xml)
        end
      end
    end
  end
end
