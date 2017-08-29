# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Relationship < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
          end

          def complete
            relationship = DataModel::Relationship.new(
              id: @attrs["id"],
              type: element_type,
              source: nil,
              target: nil,
              name: DataModel::LangString.string(process_text(@attrs["name"])),
              access_type: parse_access_type(@attrs["accessType"]),
              documentation: documentation,
              properties: properties
            )
            [
              event(:on_relationship, relationship),
              event(:on_referenceable, relationship),
              event(:on_future, Sax::FutureReference.new(relationship, :source, @attrs["source"])),
              event(:on_future, Sax::FutureReference.new(relationship, :target, @attrs["target"]))
            ]
          end

          def parse_access_type(val)
            return nil unless val && !val.empty?
            i = val.to_i
            return nil unless (0..DataModel::ACCESS_TYPE.size - 1).cover?(i)
            DataModel::ACCESS_TYPE[i]
          end
        end
      end
    end
  end
end
