# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Property < FileFormats::Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
          end

          def complete
            key = @attrs["key"]
            return [] unless key
            events = []
            if property_definitions.key?(key)
              prop_def = property_definitions[key]
            else
              prop_def = DataModel::PropertyDefinition.new(
                id: DataModel::PropertyDefinition.identifier_for_key(key),
                name: DataModel::LangString.string(process_text(key)),
                documentation: nil,
                type: "string"
              )
              events << event(:on_property_definition, prop_def)
              events << event(:on_referenceable, prop_def)
            end
            property = DataModel::Property.new(
              value: DataModel::LangString.string(process_text(@attrs["value"])),
              property_definition: prop_def
            )

            events << event(:on_property, property)
            events
          end
        end
      end
    end
  end
end
