# frozen_string_literal: true

module Archimate
  module FileFormats
    module Serializer
      module Archi
        module Diagram
          def serialize_diagram(xml, diagram)
            xml.element(
              {
                "xsi:type" => diagram.type || "archimate:ArchimateDiagramModel",
                "id" => diagram.id,
                "name" => diagram.name,
                "connectionRouterType" => diagram.connection_router_type,
                "viewpoint" => serialize_viewpoint(diagram.viewpoint),
                "background" => diagram.background
              }.compact
            ) do
              serialize(xml, diagram.nodes)
              serialize_documentation(xml, diagram.documentation)
              serialize(xml, diagram.properties)
            end
          end
        end
      end
    end
  end
end
