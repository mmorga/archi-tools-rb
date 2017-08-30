# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Property
          def serialize_property(xml, property)
            xml.property(remove_nil_values(key: property.key, value: property.value))
          end
        end
      end
    end
  end
end
