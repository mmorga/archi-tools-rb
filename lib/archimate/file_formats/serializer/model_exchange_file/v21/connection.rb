# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Connection
            def serialize_connection(xml, sc)
              xml.connection(
                identifier: identifier(sc.id),
                relationshipref: identifier(sc.relationship&.id),
                source: identifier(sc.source&.id),
                target: identifier(sc.target&.id)
              ) do
                serialize(xml, sc.bendpoints)
                serialize(xml, sc.style)
              end
            end
          end
        end
      end
    end
  end
end
