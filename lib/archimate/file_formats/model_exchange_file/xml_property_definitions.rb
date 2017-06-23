# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      # Property Definitions as defined in ArchiMate 3.0 Model Exchange XSDs
      class XmlPropertyDefinitions
        def initialize(property_defs)
          @property_definitions = property_defs
        end

        def serialize(xml)
          return if @property_definitions.empty?
          xml.propertyDefinitions do
            @property_definitions.each do |property_def|
              xml.propertyDefinition(
                "identifier" => property_def.id,
                "type" => property_def.value_type
              ) do
                ModelExchangeFile::XmlLangString.new(property_def.name, :name).serialize(xml)
              end
            end
          end
        end
      end
    end
  end
end
