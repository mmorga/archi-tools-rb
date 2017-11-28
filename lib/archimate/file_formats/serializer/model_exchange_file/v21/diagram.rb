# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module ModelExchangeFile
        module V21
          module Diagram
            def serialize_diagram(xml, diagram)
              xml.view(
                {
                  identifier: identifier(diagram.id),
                  viewpoint: viewpoint_attribute(diagram.viewpoint),
                  "xsi:type": diagram.type
                }.compact
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
