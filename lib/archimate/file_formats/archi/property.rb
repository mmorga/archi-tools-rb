# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Property < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @documentation = nil
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
              name: DataModel::LangString.string(key),
              documentation: nil,
              type: "string"
            )
            events << event(:on_property_definition, prop_def)
            events << event(:on_referenceable, prop_def)
          end
          property = DataModel::Property.new(
            value: DataModel::LangString.string(@attrs["value"]),
            property_definition: prop_def
          )

          events << event(:on_property, property)
          events
        end

        def on_documentation(documentation, source)
          @documentation = documentation
          false
        end
      end
    end
  end
end
