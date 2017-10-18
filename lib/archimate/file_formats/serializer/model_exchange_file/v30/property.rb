# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V30
          module Property
            def serialize_property(xml, property)
              xml.property("propertyDefinitionRef" => property.property_definition.id) do
                XmlLangString.new(property.value, :value).serialize(xml)
              end
            end
          end
        end
      end
    end
  end
end
