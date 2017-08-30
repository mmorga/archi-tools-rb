# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Diagram
            def serialize_diagram(xml, diagram)
              xml.view(
                remove_nil_values(
                  identifier: identifier(diagram.id),
                  viewpoint: diagram.viewpoint_type,
                  "xsi:type": diagram.type
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
