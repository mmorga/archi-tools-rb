# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Property
          def serialize_property(xml, property)
            xml.property({ key: property.key, value: property.value }.compact)
          end
        end
      end
    end
  end
end
