# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Relationship < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @rel_name = nil
            @relationship = nil
          end

          def complete
            [
              event(:on_relationship, relationship),
              event(:on_referenceable, relationship),
              event(:on_future, Sax::FutureReference.new(relationship, :source, attrs["source"])),
              event(:on_future, Sax::FutureReference.new(relationship, :target, attrs["target"]))
            ]
          end

          def on_lang_string(name, _source)
            @rel_name = name
            false
          end

          private

          def relationship
            @relationship ||= DataModel::Relationships.create(
              id: attrs["identifier"],
              type: attrs["xsi:type"],
              source: nil,
              target: nil,
              name: @rel_name,
              access_type: attrs["accessType"],
              documentation: documentation,
              properties: properties
            )
          end
        end
      end
    end
  end
end
