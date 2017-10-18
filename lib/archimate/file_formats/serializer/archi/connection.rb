# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Connection
          def serialize_connection(xml, connection)
            xml.sourceConnection(
              remove_nil_values(
                {
                  "xsi:type" => connection.type,
                  "id" => connection.id,
                  "name" => connection.name
                }.merge(
                  archi_style_hash(connection.style).merge(
                    "source" => connection.source&.id,
                    "target" => connection.target&.id,
                    "relationship" => connection.relationship&.id
                  )
                )
              )
            ) do
              serialize(xml, connection.bendpoints)
              serialize_documentation(xml, connection.documentation)
              serialize(xml, connection.properties)
            end
          end
        end
      end
    end
  end
end
