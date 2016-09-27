# frozen_string_literal: true
require 'ox'

module Archimate
  module Conversion
    class MeffFromArchi
      def self.meff_from_archi(archidoc, io)
        model = archidoc.root
        builder = Ox::Builder.io(io) do |xml|
          xml.element(
            "model",
            "xmlns" => "http://www.opengroup.org/xsd/archimate",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "identifier" => "id-#{model['id']}",
            "xsi:schemaLocation" => "http://www.opengroup.org/xsd/archimate " \
              "http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd"
          ) do
            xml.element("name", "xml:lang" => "en") { xml.text model["name"] }
            documentation(xml, model.at_xpath("purpose"))
            elements(
              xml,
              model.xpath("//element[not(@source) and " \
                "not(@xsi:type='archimate:ArchimateDiagramModel')]")
            )
            relationships(xml, model.xpath("//element[@source]"))
            organization(xml, model.xpath("/*/folder"))
            xml.element("propertydefs") do
              keys = property_keys(archidoc)
              keys << "JunctionType"
              keys.sort.each do |key|
                xml.element(
                  "propertydef",
                  "identifier" => key == "JunctionType" ? "propid-junctionType" : property_def_id(archidoc, key),
                  "name" => key,
                  "type" => "string"
                ) {}
              end
            end
            views(xml, model)
          end
        end
        builder
      end

      def self.documentation(xml, doc)
        unless doc.nil?
          if doc.content.strip.empty?
            xml.element("documentation", "xml:lang" => "en") {}
          else
            xml.element("documentation", "xml:lang" => "en") { xml.text text_proc(doc.content) }
          end
        end
      end

      def self.elements(xml, elements)
        xml.element("elements") do
          elements.each do |element|
            next if element.attr("xsi:type") == "archimate:SketchModel"
            xml.element(
              "element",
              identifier: "id-#{element['id']}",
              "xsi:type" => meff_type(element.attr("xsi:type"))
            ) do
              elementbase(xml, element)
            end
          end
        end
      end

      def self.elementbase(xml, element)
        label(xml, element["name"])
        documentation(xml, element.at_xpath("documentation"))
        properties(xml, element)
      end

      def self.label(xml, str)
        unless str.nil? || str.strip.empty?
          xml.element("label", "xml:lang" => "en") { xml.text text_proc(str) }
        end
      end

      def self.relationships(xml, relationships)
        xml.element("relationships") do
          relationships.each do |relationship|
            xml.element(
              "relationship",
              identifier: "id-#{relationship['id']}",
              source: "id-#{relationship['source']}",
              target: "id-#{relationship['target']}",
              "xsi:type" => meff_type(relationship.attr("xsi:type"))
            ) do
              elementbase(xml, relationship)
            end
          end
        end
      end

      def self.organization(xml, folders)
        xml.element("organization") do
          folders(xml, folders)
        end
      end

      def self.folders(xml, folders)
        # match="folder"
        #     Looks like if test="fn:count(element) > 0" is used to render only folders
        #     with contents in Archi export of MEFF
        # -%>
        folders.each do |folder|
          next if folder.xpath(".//element").empty?
          xml.element("item") do
            label(xml, folder["name"])
            documentation(xml, folder.at_xpath("documentation"))
            folders(xml, folder.xpath("folder"))
            folder.xpath("element").each do |el|
              xml.element("item", identifierref: "id-#{el['id']}") {}
            end
          end
        end
      end

      def self.property_keys(doc)
        keys = []
        doc.xpath("//property/@key").each do |key_attr|
          keys << key_attr.value
        end
        keys.uniq
      end

      def self.property_def_id(doc, key)
        "propid-#{property_keys(doc).find_index(key) + 1}"
      end

      def self.properties(xml, element)
        properties = element.xpath("property")
        if !properties.empty? ||
           %w(archimate:AndJunction archimate:OrJunction).include?(element.attr("xsi:type"))
          xml.element("properties") do
            properties.each do |property|
              next unless property.has_attribute?("key") && !property["key"].empty?
              xml.element("property", identifierref: property_def_id(properties.document, property["key"])) do
                if property["value"].nil? || property["value"].strip.empty?
                  xml.element("value", "xml:lang" => "en") {}
                else
                  xml.element("value", "xml:lang" => "en") { xml.text property["value"].strip }
                end
              end
            end
            if element.attr("xsi:type") == "archimate:AndJunction"
              xml.element("property", identifierref: "propid-junctionType") do
                xml.element("value", "xml:lang" => "en") { xml.text "AND" }
              end
            elsif element.attr("xsi:type") == "archimate:OrJunction"
              xml.element("property", identifierref: "propid-junctionType") do
                xml.element("value", "xml:lang" => "en") { xml.text "OR" }
              end
            end
          end
        end
      end

      # Views is an element of xsi:type ArchimateDiagramModel
      # "//element[@xsi:type='archimate:ArchimateDiagramModel']"
      def self.views(xml, model)
        xml.element("views") do
          model.xpath("//folder[@type='diagrams']").each do |folder|
            view_folder(xml, folder)
          end
        end
      end

      def self.view_folder(xml, folder)
        folder.xpath("element[@xsi:type='archimate:ArchimateDiagramModel']").each do |view|
          # view_elements = model.xpath("//element[@xsi:type='archimate:ArchimateDiagramModel']")
          # view_elements.each do |view|
          xml.element("view", identifier: "id-#{view['id']}") do
            elementbase(xml, view)
            node(xml, view.xpath("child"))
            source_connection(xml, view.xpath("child"))
          end
        end
        folder.xpath("folder").each do |f|
          view_folder(xml, f)
        end
      end

      def self.node(xml, nodes, x_offset = 0, y_offset = 0)
        nodes.each do |node|
          node_attrs = {
            h: to_int(float_val(node.at_xpath("bounds/@height"))).to_s,
            identifier: "id-#{node['id']}",
            w: to_int(float_val(node.at_xpath("bounds/@width"))).to_s,
            x: to_int(float_val(node.at_xpath("bounds/@x")) + x_offset).to_s,
            y: to_int(float_val(node.at_xpath("bounds/@y")) + y_offset).to_s
          }
          if node.attributes.include?("archimateElement")
            node_attrs["elementref"] = "id-#{node['archimateElement']}"
          elsif node.attributes.include?("model")
            # Since it doesn't seem to be forbidden, we just assume we can use
            # the elementref for views in views
            node_attrs["elementref"] = node["model"]
            node_attrs["type"] = "model"
          else
            node_attrs["type"] = "group"
          end
          xml.element("node", node_attrs) do
            label(xml, node["name"]) if node_attrs["type"] == "group"
            if node.attributes.include?("fillColor")
              xml.element("style") do
                xml.element("fillColor", hex_to_rgb(node["fillColor"])) {}
                # TODO: calculate  relative line color
                xml.element("lineColor", b: "92", g: "92", r: "92") {}
              end
            else
              ref_element = node.at_xpath("//element[@id='#{node['archimateElement']}']/@xsi:type")
              ref_element = ref_element.nil? ? "" : ref_element.value
              default_color(xml, ref_element)
            end
            node(xml, node.xpath("child"), node_attrs[:x].to_f, node_attrs[:y].to_f)
          end
        end
      end

      def self.default_color(xml, element)
        case element
        when 'archimate:BusinessRole', 'archimate:BusinessActor',
             'archimate:BusinessCollaboration', 'archimate:Product',
             'archimate:Location', 'archimate:BusinessInterface',
             'archimate:BusinessFunction', 'archimate:BusinessProcess',
             'archimate:BusinessEvent', 'archimate:BusinessInteraction',
             'archimate:Contract', 'archimate:BusinessService',
             'archimate:Value', 'archimate:Meaning',
             'archimate:Representation', 'archimate:BusinessObject'
          xml.element("style") do
            xml.element("fillColor", b: "181", g: "255", r: "255") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:ApplicationComponent', 'archimate:ApplicationCollaboration',
             'archimate:ApplicationInterface', 'archimate:ApplicationService',
             'archimate:ApplicationFunction', 'archimate:ApplicationInteraction',
             'archimate:DataObject'
          xml.element("style") do
            xml.element("fillColor", b: "255", g: "255", r: "181") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:Device', 'archimate:Node', 'archimate:SystemSoftware',
                'archimate:CommunicationPath', 'archimate:Artifact',
                'archimate:Network', 'archimate:InfrastructureInterface',
                'archimate:InfrastructureFunction', 'archimate:InfrastructureService'
          xml.element("style") do
            xml.element("fillColor", b: "183", g: "231", r: "201") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:Principle', 'archimate:Goal', 'archimate:Requirement',
            'archimate:Constraint'
          xml.element("style") do
            xml.element("fillColor", b: "255", g: "204", r: "204") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:Gap', 'archimate:Plateau'
          xml.element("style") do
            xml.element("fillColor", b: "224", g: "255", r: "224") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:Workpackage', 'archimate:Deliverable'
          xml.element("style") do
            xml.element("fillColor", b: "224", g: "224", r: "255") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:Stakeholder', 'archimate:Driver', 'archimate:Assessment'
          xml.element("style") do
            xml.element("fillColor", b: "255", g: "223", r: "191") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:AndJunction'
          xml.element("style") do
            xml.element("fillColor", b: "0", g: "0", r: "0") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        when 'archimate:OrJunction'
          xml.element("style") do
            xml.element("fillColor", b: "255", g: "255", r: "255") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        else
          xml.element("style") do
            xml.element("fillColor", b: "192", g: "192", r: "192") {}
            xml.element("lineColor", b: "92", g: "92", r: "92") {}
          end
        end
      end

      def self.source_connection(xml, children, x_offset = 0, y_offset = 0)
        # TODO: don't include relationshipref attr if no relationship
        children.each do |child|
          child.xpath("sourceConnection").each do |sc|
            bounds = sc.at_xpath("bounds")
            if bounds.nil?
              x_offset += 0
              y_offset += 0
            else
              x_offset += bounds.has_attribute?("x") ? bounds["x"].to_f : 0
              y_offset += bounds.has_attribute?("y") ? bounds["y"].to_f : 0
            end
            xml.element(
              "connection",
              identifier: "id-#{sc['id']}",
              relationshipref: "id-#{sc['relationship']}",
              source: "id-#{sc['source']}",
              target: "id-#{sc['target']}"
            ) do
              bendpoint(xml, sc.xpath("bendpoint"), x_offset, y_offset)
              xml.element("style") do
                if sc.has_attribute?("lineColor")
                  xml.element("lineColor", hex_to_rgb(sc["lineColor"])) {}
                else
                  xml.element("lineColor", b: "0", g: "0", r: "0") {}
                end
              end
            end
            source_connection(xml, child.xpath("child"), x_offset, y_offset)
          end
        end
      end

      def self.bendpoint(xml, bendpoints, x_offset, y_offset)
        bendpoints.each do |bp|
          sourceid = bp.at_xpath("../@source")
          source = bp.at_xpath("//child[@id=\"#{sourceid}\"]")
          bounds = source.at_xpath("bounds")
          if bounds.nil?
            bx = 0
            by = 0
            bw = 0
            bh = 0
          else
            bx = bounds.has_attribute?("x") ? bounds["x"].to_f : 0
            by = bounds.has_attribute?("y") ? bounds["y"].to_f : 0
            bw = bounds.has_attribute?("width") ? bounds["width"].to_f : 0
            bh = bounds.has_attribute?("height") ? bounds["height"].to_f : 0
          end
          x = to_int(bx + x_offset + (bw / 2) + bp["startX"].to_f)
          y = to_int(by + y_offset + (bh / 2) + bp["startY"].to_f)

          xml.element("bendpoint", x: x.to_s, y: y.to_s) {}
        end
      end

      def self.meff_type(el_type)
        el_type = el_type.sub(/^archimate:/, "")
        case el_type
        when 'AndJunction', 'OrJunction'
          'Junction'
        else
          el_type
        end
      end

      def self.text_proc(str)
        str.strip.tr("\r", "\n")
      end

      def self.hex_to_rgb(_str)
        # TODO: implement me
        { b: "255", g: "255", r: "181" }
      end

      def self.to_int(fval)
        fval.round.to_i
      end

      def self.float_val(node)
        node.nil? ? 0.0 : node.value.to_f
      end
    end
  end
end
