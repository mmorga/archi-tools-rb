# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class Element < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @element = nil
          end

          def complete
            [
              event(:on_element, element),
              event(:on_referenceable, element)
            ]
          end

          private

          def element
            @element ||= DataModel::Elements.create(
              id: @attrs["id"],
              name: DataModel::LangString.string(process_text(@attrs["name"])),
              type: mapped_element_type,
              documentation: documentation,
              properties: properties
            )
          end

          def mapped_element_type
            case element_type
            when "Junction"
              @attrs["type"] == "or" ? "OrJunction" : "AndJunction"
            else
              element_type
            end
          end
        end
      end
    end
  end
end
