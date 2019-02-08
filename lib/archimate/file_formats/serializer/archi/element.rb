# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Element
          def serialize_element(xml, element)
            xml.element(element_attrs(element)) do
              serialize_documentation(xml, element.documentation)
              serialize(xml, element.properties)
            end
          end

          def element_attrs(element)
            {
              "xsi:type" => "archimate:#{mapped_element_name(element)}",
              "id" => element.id,
              "name" => element.name,
              "type" => element.is_a?(DataModel::Elements::OrJunction) ? "or" : nil
            }.compact
          end

          def mapped_element_name(element)
            case element
            when DataModel::Elements::AndJunction, DataModel::Elements::OrJunction
              "Junction"
            else
              element.type
            end
          end
        end
      end
    end
  end
end
