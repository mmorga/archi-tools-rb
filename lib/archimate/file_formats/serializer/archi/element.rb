# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Element
          def serialize_element(xml, element)
            xml.element(
              {
                "xsi:type" => "archimate:#{element.type}",
                "id" => element.id,
                "name" => element.name
              }.compact
            ) do
              serialize_documentation(xml, element.documentation)
              serialize(xml, element.properties)
            end
          end
        end
      end
    end
  end
end
