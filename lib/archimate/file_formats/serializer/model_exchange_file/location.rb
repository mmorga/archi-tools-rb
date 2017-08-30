# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module Location
          def serialize_location(xml, location)
            xml.bendpoint(x: location.x.round, y: location.y.round)
          end
        end
      end
    end
  end
end
