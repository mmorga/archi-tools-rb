# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class SchemaInfo < FileFormats::Sax::Handler
          def initialize(name, attrs, parent_handler)
            super
            @schema_infos = []
            @schema = nil
            @schema_version = nil
            @elements = []
          end

          def complete
            [
              event(
                :on_schema_info,
                DataModel::SchemaInfo.new(
                  schema: @schema,
                  schemaversion: @schema_version,
                  elements: @elements
                )
              )
            ]
          end

          def on_schema(string, _source)
            @schema = string
            false
          end

          def on_schemaversion(string, _source)
            @schema_version = string
            false
          end

          def on_any_element(any_element, _source)
            @elements << any_element
            false
          end
        end
      end
    end
  end
end
