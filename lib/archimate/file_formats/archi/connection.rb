# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Connection < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @bendpoints = []
          @documentation = nil
          @properties = []
          @style = nil
        end

        def complete
          connection = DataModel::Connection.new(
            id: @attrs["id"],
            type: @attrs["xsi:type"],
            source: nil,
            target: nil,
            relationship: nil,
            name: @attrs["name"],
            style: @style,
            bendpoints: @bendpoints,
            documentation: @documentation,
            properties: @properties
          )
          [
            event(:on_connection, connection),
            event(:on_referenceable, connection),
            event(:on_future, FutureReference.new(connection, :source, @attrs["source"])),
            event(:on_future, FutureReference.new(connection, :target, @attrs["target"])),
            event(:on_future, FutureReference.new(connection, :relationship, @attrs["relationship"]))
          ]
        end

        def on_documentation(documentation, source)
          @documentation = documentation
          false
        end

        def on_property(property, source)
          @properties << property
          false
        end

        def on_location(location, source)
          @bendpoints << location
          false
        end

        def on_style(style, source)
          @style = style
          false
        end
      end
    end
  end
end
