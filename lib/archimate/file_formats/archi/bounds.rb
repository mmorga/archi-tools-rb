# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Bounds < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @bounds = DataModel::Bounds.new(
            x: @attrs["x"],
            y: @attrs["y"],
            width: @attrs["width"],
            height: @attrs["height"]
          )
        end

        def complete
          [event(:on_bounds, @bounds)]
        end
      end
    end
  end
end
