# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module Element
          def serialize_element(xml, element)
            return if element.type == "SketchModel" # TODO: print a warning that data is lost
            xml.element(identifier: identifier(element.id),
                        "xsi:type" => meff_type(element.type)) do
              elementbase(xml, element)
            end
          end

          def elementbase(xml, element)
            serialize_label(xml, element.name)
            serialize(xml, element.documentation)
            serialize_properties(xml, element)
          end
        end
      end
    end
  end
end
