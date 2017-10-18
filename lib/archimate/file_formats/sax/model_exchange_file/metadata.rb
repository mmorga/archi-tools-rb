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
            @metadata = nil
            @lone_schema_info = nil
          end

          def complete
            [
              event(:on_metadata, metadata)
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

          def on_schema_info(schema_info, _source)
            @schema_infos << schema_info
            false
          end

          private

          def metadata
            return @metadata if @metadata
            @schema_infos << lone_schema_info if @schema
            @metadata = DataModel::Metadata.new(
              schema_infos: @schema_infos
            )
          end

          def lone_schema_info
            return nil unless @schema
            @lone_schema_info = DataModel::SchemaInfo.new(
              schema: @schema,
              schemaversion: @schema_version,
              elements: @elements
            )
          end
        end
      end
    end
  end
end
