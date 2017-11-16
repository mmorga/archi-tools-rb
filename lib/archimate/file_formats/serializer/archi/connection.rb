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
                    "archimateRelationship" => connection.relationship&.id
                  )
                )
              )
            ) do
              connection.bendpoints.each do |bendpoint|
                serialize_bendpoint(xml, bendpoint, connection)
              end
              serialize_documentation(xml, connection.documentation)
              serialize(xml, connection.properties)
            end
          end

          # startX = bendpoint.x - start_location.x
          # startY = bendpoint.y - start_location.y
          def serialize_bendpoint(xml, bendpoint, connection)
            xml.bendpoint(
              {
                startX: (bendpoint.x - connection.start_location.x).to_i,
                startY: (bendpoint.y - connection.start_location.y).to_i,
                endX: (bendpoint.x - connection.end_location.x).to_i,
                endY: (bendpoint.y - connection.end_location.y).to_i
              }.delete_if { |_k, v| v.zero? }
            )
          end
        end
      end
    end
  end
end
