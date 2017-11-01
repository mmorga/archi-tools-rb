# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module ModelExchangeFile
        class Element < FileFormats::Sax::Handler
          include Sax::CaptureDocumentation
          include Sax::CaptureProperties

          def initialize(name, attrs, parent_handler)
            super
            @name = nil
          end

          def complete
            [
              event(:on_element, element),
              event(:on_referenceable, element)
            ]
          end

          def on_lang_string(str, _source)
            @name = str
            false
          end

          private

          def element
            @element ||= DataModel::Elements.create(
              id: attrs["identifier"],
              name: name,
              type: element_type,
              documentation: documentation,
              properties: properties
            )
          end
        end
      end
    end
  end
end
