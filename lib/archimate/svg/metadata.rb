# frozen_string_literal: true

module Archimate
  module Svg
    # Metadata to be added to the SVG file
    # <metadata>
    #   <rdf:RDF
    #            xmlns:rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    #            xmlns:rdfs = "http://www.w3.org/2000/01/rdf-schema#"
    #            xmlns:dc = "http://purl.org/dc/elements/1.1/" >
    #     <rdf:Description about="http://example.org/myfoo"
    #                       dc:title="MyFoo Financial Report"
    #                       dc:description="$three $bar $thousands $dollars $from 1998 $through 2000"
    #                       dc:publisher="Example Organization"
    #                       dc:date="2000-04-11"
    #                       dc:format="image/svg+xml"
    #                       dc:language="en" >
    #       <dc:creator>
    #         <rdf:Bag>
    #           <rdf:li>Irving Bird</rdf:li>
    #           <rdf:li>Mary Lambert</rdf:li>
    #         </rdf:Bag>
    #       </dc:creator>
    #     </rdf:Description>
    #   </rdf:RDF>
    # </metadata>
    #
    # Diagram:
    #   Archimate tools as dc:creator or FOAF:maker
    #   dc:creator for the author of the diagram
    #   dc:contributor for other authors of the diagram
    # For any other node
    #   If they have documentation:
    #     dc:description
    #   Properties
    #     rdf:Property
    #       rdf:label
    #       rdf:value
    class Metadata
      def render_metadata(svg, node)
        Nokogiri::XML::Builder.with(svg) do |xml|
          case node
          when DataModel::Diagram
            render_diagram_metadata(xml, node)
          else
            render_node_metadata(xml, node)
          end
        end
        svg
      end

      def render_node_metadata(xml, node)
        metadata_envelope(xml) do
          node_metadata(xml, node)
        end
      end

      def node_metadata(xml, node)
        xml['dc'].description do
          xml['rdf'].Bag do
            node.documentation.each do |doc|
              xml['rdf'].p { xml.text doc.text }
            end
          end
        end
        node.properties.each do |property|
          xml['rdf'].Property("rdf:lang" => property.lang) do
            xml['rdf'].label { xml.text property.key }
            xml['rdf'].value { xml.text property.value }
          end
        end
      end

      def render_diagram_metadata(xml, diagram)
        metadata_envelope(xml) do
          diagram_metadata(xml, diagram)
          node_metadata(xml, diagram)
        end
      end

      def diagram_metadata(xml, diagram)
        xml['dc'].title { xml.text diagram.name }
        xml['dc'].creator do
          xml['rdf'].Bag do
            xml['rdf'].li { xml.text "Archimate Tools" }
          end
        end
      end

      def metadata_envelope(xml)
        xml.metadata do
          xml['rdf'].RDF(
            "xmlns:rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
            "xmlns:rdfs" => "http://www.w3.org/2000/01/rdf-schema#",
            "xmlns:dc" => "http://purl.org/dc/elements/1.1/"
          ) do
            xml['rdf'].Description { yield }
          end
        end
      end
    end
  end
end
