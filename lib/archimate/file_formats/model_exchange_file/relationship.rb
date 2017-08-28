# frozen_string_literal: true

module Archimate
  module FileFormats
    module ModelExchangeFile
      class Relationship < FileFormats::Sax::Handler
        include Sax::CaptureDocumentation
        include Sax::CaptureProperties

        def initialize(name, attrs, parent_handler)
          super
          @rel_name = nil
        end

        def complete
          relationship = DataModel::Relationship.new(
            id: attrs["identifier"],
            type: attrs["xsi:type"],
            source: nil,
            target: nil,
            name: @rel_name,
            access_type: parse_access_type(attrs["accessType"]),
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
          return nil unless val && val.size > 0
          attrs = val.to_i
          return nil unless (0..DataModel::ACCESS_TYPE.size-1).include?(attrs)
          DataModel::ACCESS_TYPE[attrs]
        end

        def on_lang_string(name, source)
          @rel_name = name
          false
        end
      end
    end
  end
end
