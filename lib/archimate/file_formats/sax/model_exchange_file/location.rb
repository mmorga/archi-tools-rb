# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
    module ModelExchangeFile
      class Location < FileFormats::Sax::Handler
        def initialize(name, attrs, parent_handler)
          super
          @location = DataModel::Location.new(
            x: @attrs["x"] || 0,
            y: @attrs["y"] || 0
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
