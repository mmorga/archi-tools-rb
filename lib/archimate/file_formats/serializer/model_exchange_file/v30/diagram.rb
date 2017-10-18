# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V30
          module Diagram
            def serialize_diagram(xml, diagram)
              xml.view(
                remove_nil_values(
                  identifier: identifier(diagram.id),
                  "xsi:type": diagram.type,
                  viewpoint: diagram.viewpoint_type
                )
              ) do
                elementbase(xml, diagram)
                serialize(xml, diagram.nodes)
                serialize(xml, diagram.connections)
              end
            end
          end
        end
      end
    end
  end
end
