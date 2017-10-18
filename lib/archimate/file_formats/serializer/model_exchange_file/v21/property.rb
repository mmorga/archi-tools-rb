# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Property
            def serialize_property(xml, property)
              xml.property(identifierref: property.property_definition.id) do
                Serializer::XmlLangString.new(property.value, :value).serialize(xml)
              end
            end
          end
        end
      end
    end
  end
end
