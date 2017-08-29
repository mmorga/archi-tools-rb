# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Location < FileFormats::Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
            @location = DataModel::Location.new(
              x: @attrs["startX"] || 0,
              y: @attrs["startY"] || 0,
              end_x: @attrs["endX"],
              end_y: @attrs["endY"]
            )
          end

          def complete
            [event(:on_location, @location)]
          end
        end
      end
    end
  end
end
