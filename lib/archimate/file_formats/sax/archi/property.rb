# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Property < FileFormats::Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
            @property = nil
            @property_def = nil
            @key = nil
            @events = []
          end

          def complete
            return [] unless key
            @events << event(
              :on_property,
              DataModel::Property.new(
                value: DataModel::LangString.string(process_text(attrs["value"])),
                property_definition: prop_def
              )
            )
          end

          private

          def key
            @key ||= attrs["key"]
          end

          def prop_def
            return property_definitions[key] if property_definitions.key?(key)

            prop_def = make_prop_def
            @events << event(:on_property_definition, prop_def)
            @events << event(:on_referenceable, prop_def)
            prop_def
          end

          def make_prop_def
            DataModel::PropertyDefinition.new(
              id: DataModel::PropertyDefinition.identifier_for_key(key),
              name: DataModel::LangString.string(process_text(key)),
              documentation: nil,
              type: "string"
            )
          end
        end
      end
    end
  end
end
