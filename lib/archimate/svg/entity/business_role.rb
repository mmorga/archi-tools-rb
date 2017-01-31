# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class BusinessRole < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-role-badge"
        end
      end
    end
  end
end
