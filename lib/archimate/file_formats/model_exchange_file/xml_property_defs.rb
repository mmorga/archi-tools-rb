# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      # Property Definitions as defined in ArchiMate 2.1 Model Exchange XSDs
      class XmlPropertyDefs
        def initialize(property_defs)
          @property_definitions = property_defs
        end

        def serialize(xml)
          return if @property_definitions.empty?
          xml.propertydefs do
            @property_definitions.each do |property_def|
              xml.propertydef(
                "identifier" => property_def.id,
                "name" => property_def.name,
                "type" => property_def.type
              )
            end
          end
        end
      end
    end
  end
end
