# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V30
          # Property Definitions as defined in ArchiMate 3.0 Model Exchange XSDs
          class PropertyDefinitions
            def initialize(property_defs)
              @property_definitions = property_defs
            end

            def serialize(xml)
              return if @property_definitions.empty?
              xml.propertyDefinitions do
                @property_definitions.each { |property_def| serialize_property_definition(xml, property_def) }
              end
            end

            def serialize_property_definition(xml, property_def)
              xml.propertyDefinition(
                "identifier" => property_def.id,
                "type" => property_def.type
              ) do
                XmlLangString.new(property_def.name, :name).serialize(xml)
              end
            end
          end
        end
      end
    end
  end
end
