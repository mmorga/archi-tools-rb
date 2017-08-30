# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Documentation
          def serialize_documentation(xml, documentation, element_name = "documentation")
            return unless documentation
            xml.send(element_name) { xml.text(documentation.text) }
          end
        end
      end
    end
  end
end
