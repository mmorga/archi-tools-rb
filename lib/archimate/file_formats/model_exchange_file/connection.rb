# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class Connection < FileFormats::Sax::Handler
        include Sax::CaptureDocumentation
        include Sax::CaptureProperties

        def initialize(name, attrs, parent_handler)
          super
          @bendpoints = []
          @connection_name = nil
          @style = nil
        end

        def complete
          connection = DataModel::Connection.new(
            id: @attrs["identifier"],
            type: @attrs["type"],
            source: nil,
            target: nil,
            relationship: nil,
            name: @connection_name,
            style: @style,
            bendpoints: @bendpoints,
            documentation: documentation,
            properties: properties
          )
          [
            event(:on_connection, connection),
            event(:on_referenceable, connection),
            event(:on_future, Sax::FutureReference.new(connection, :source, @attrs["source"])),
            event(:on_future, Sax::FutureReference.new(connection, :target, @attrs["target"])),
            event(:on_future, Sax::FutureReference.new(connection, :relationship, @attrs["relationshipref"]))
          ]
        end

        def on_location(location, source)
          @bendpoints << location
          false
        end

        def on_style(style, source)
          @style = style
          false
        end

        def on_lang_string(name, source)
          @connection_name = name
          false
        end
      end
    end
  end
end
