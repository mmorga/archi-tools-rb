# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
    module ModelExchangeFile
      class Metadata < FileFormats::Sax::Handler
        def initialize(name, attrs, parent_handler)
          super
          @schema_infos = []
          @schema = nil
          @schema_version = nil
          @elements = []
        end

        def complete
          if @schema
            @schema_infos << DataModel::SchemaInfo.new(
              schema: @schema,
              schemaversion: @schema_version,
              elements: @elements)
          end
          metadata = DataModel::Metadata.new(
            schema_infos: @schema_infos
          )
          [
            event(:on_metadata, metadata)
          ]
        end

        def on_schema(string, source)
          @schema = string
          false
        end

        def on_schemaversion(string, source)
          @schema_version = string
          false
        end

        def on_any_element(any_element, source)
          @elements << any_element
          false
        end

        def on_schema_info(schema_info, source)
          @schema_infos << schema_info
          false
        end
      end
    end
  end
end
end
