# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Connection < FileFormats::Sax::Handler
          include Style
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @bendpoints = []
          end

          def complete
            connection = DataModel::Connection.new(
              id: @attrs["id"],
              type: @attrs["xsi:type"],
              source: nil,
              target: nil,
              relationship: nil,
              name: @attrs["name"],
              style: style,
              bendpoints: @bendpoints,
              documentation: documentation,
              properties: properties
            )
            [
              event(:on_connection, connection),
              event(:on_referenceable, connection),
              event(:on_future, Sax::FutureReference.new(connection, :source, @attrs["source"])),
              event(:on_future, Sax::FutureReference.new(connection, :target, @attrs["target"])),
              event(:on_future, Sax::FutureReference.new(connection, :relationship, @attrs["relationship"] || @attrs["archimateRelationship"]))
            ]
          end

          def on_location(location, _source)
            @bendpoints << location
            false
          end
        end
      end
    end
  end
end
