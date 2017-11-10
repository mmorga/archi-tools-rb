# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Connection < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @bendpoints = []
            @connection_name = nil
            @style = nil
            @connection = nil
          end

          def complete
            [
              event(:on_connection, connection),
              event(:on_referenceable, connection),
              event(:on_future,
                    Sax::FutureReference.new(connection, :source, attrs["source"])),
              event(:on_future,
                    Sax::FutureReference.new(connection, :target, attrs["target"])),
              event(:on_future,
                    Sax::FutureReference.new(connection,
                                             :relationship,
                                             attrs["relationshipRef"] || attrs["relationshipref"]))
            ]
          end

          def on_location(location, _source)
            @bendpoints << location
            false
          end

          def on_style(style, _source)
            @style = style
            false
          end

          def on_lang_string(name, _source)
            @connection_name = name
            false
          end

          private

          def connection
            @connection ||= DataModel::Connection.new(id: attrs["identifier"],
                                                      type: attrs["xsi:type"] || attrs["type"],
                                                      source: nil,
                                                      target: nil,
                                                      relationship: nil,
                                                      name: @connection_name,
                                                      style: @style,
                                                      bendpoints: @bendpoints,
                                                      documentation: documentation,
                                                      properties: properties,
                                                      diagram: diagram)
          end
        end
      end
    end
  end
end
