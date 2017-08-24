# frozen_string_literal: true

module Archimate
  module FileFormats
    module Archi
      class Element < FileFormats::SaxHandler
        include CaptureDocumentation
        include CaptureProperties

        def initialize(attrs, parent_handler)
          super
        end

        def complete
          element = DataModel::Element.new(
            id: @attrs["id"],
            name: DataModel::LangString.string(process_text(@attrs["name"])),
            type: element_type,
            documentation: documentation,
            properties: properties
          )
          [
            event(:on_element, element),
            event(:on_referenceable, element)
          ]
        end
      end
    end
  end
end
