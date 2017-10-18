# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V30
          module Connection
            def serialize_connection(xml, sc)
              xml.connection(
                identifier: identifier(sc.id),
                relationshipRef: identifier(sc.relationship&.id),
                "xsi:type": sc.type,
                source: identifier(sc.source&.id),
                target: identifier(sc.target&.id)
              ) do
                serialize(xml, sc.style)
                serialize(xml, sc.bendpoints)
              end
            end
          end
        end
      end
    end
  end
end
