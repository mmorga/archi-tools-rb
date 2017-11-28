# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Bounds
          def serialize_bounds(xml, bounds)
            return unless bounds
            xml.bounds(
              {
                x: bounds.x&.to_i,
                y: bounds.y&.to_i,
                width: bounds.width&.to_i,
                height: bounds.height&.to_i
              }.compact
            )
          end
        end
      end
    end
  end
end
