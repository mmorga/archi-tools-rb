# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Element < FileFormats::SaxHandler
        def initialize(attrs, parent_handler)
          super
          @documentation = nil
          @properties = []
        end

        def complete
          element = DataModel::Element.new(
            id: @attrs["id"],
            name: DataModel::LangString.string(@attrs["name"]),
            type: element_type,
            documentation: @documentation,
            properties: @properties
          )
          [
            event(:on_element, element),
            event(:on_referenceable, element)
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
      end
    end
  end
end
