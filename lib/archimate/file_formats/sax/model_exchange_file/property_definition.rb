# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class PropertyDefinition < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation

          def initialize(name, attrs, parent_handler)
            super
            @prop_def_name = @attrs["name"]
          end

          def complete
            property_def = DataModel::PropertyDefinition.new(
              id: attrs["identifier"],
              name: @prop_def_name,
              documentation: documentation,
              type: attrs["type"]
            )
            [
              event(:on_property_definition, property_def),
              event(:on_referenceable, property_def)
            ]
          end

          def on_lang_string(name, _source)
            @prop_def_name = name
            false
          end
        end
      end
    end
  end
end
