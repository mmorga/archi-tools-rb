# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class BusinessCollaboration < RectEntity
        def initialize(child, bounds_offset)
          super
          @badge = "#archimate-collaboration-badge"
        end
      end
    end
  end
end
