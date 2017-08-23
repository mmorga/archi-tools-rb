# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Relationship < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @documentation = nil
          @properties = []
        end

        def complete
          relationship = DataModel::Relationship.new(
            id: @attrs["id"],
            type: element_type,
            source: nil,
            target: nil,
            name: DataModel::LangString.string(@attrs["name"]),
            access_type: parse_access_type(@attrs["accessType"]),
            documentation: @documentation,
            properties: @properties
          )
          [
            event(:on_relationship, relationship),
            event(:on_referenceable, relationship),
            event(:on_future, FutureReference.new(relationship, :source, @attrs["source"])),
            event(:on_future, FutureReference.new(relationship, :target, @attrs["target"]))
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

        def parse_access_type(val)
          return nil unless val && val.size > 0
          i = val.to_i
          return nil unless (0..DataModel::ACCESS_TYPE.size-1).include?(i)
          DataModel::ACCESS_TYPE[i]
        end
      end
    end
  end
end
