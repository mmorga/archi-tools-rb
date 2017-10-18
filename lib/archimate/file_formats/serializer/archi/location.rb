# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Location
          # startX = location.x - source_attachment.x
          # startY = location.y - source_attachment.y
          # endX = location.x - target_attachment.x
          # endY = location.y - source_attachment.y
          def serialize_location(xml, bendpoint)
            xml.bendpoint(
              remove_nil_values(
                startX: bendpoint.x == 0 ? nil : bendpoint.x&.to_i,
                startY: bendpoint.y == 0 ? nil : bendpoint.y&.to_i,
                endX: bendpoint.end_x&.to_i,
                endY: bendpoint.end_y&.to_i
              )
            )
          end
        end
      end
    end
  end
end
