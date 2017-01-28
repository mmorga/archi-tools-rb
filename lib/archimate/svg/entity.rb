# frozen_string_literal: true
module Archimate
  module Svg
    class Entity
      using StringRefinements

      attr_reader :child
      attr_reader :entity
      attr_reader :bounds_offset
      attr_reader :text_bounds

      # shape (+ class: layer)
      #   badge (shape knows badge position)
      #   text (shape knows region for text)
      EntityProperties = Struct.new(:shape, :layer, :badge)

      def initialize(child, bounds_offset)
        @child = child
        @text_bounds = child.bounds
        @bounds_offset = bounds_offset
        @entity = @child.element || @child
        raise "Hell!" if @entity.nil?
      end

      def to_svg(xml)
        eprops = entity_properties
        xml.g(group_attrs) do
          xml.title { xml.text @entity.name } unless @entity.name.nil? || @entity.name.empty?
          xml.desc { xml.text(@entity.documentation.map(&:text).join("\n\n")) } unless @entity.documentation.empty?
          send(eprops.shape, xml, child.bounds, eprops)
          entity_badge(xml, eprops)
          entity_label(xml, eprops)
          child.children.each { |c| Entity.new(c, child.bounds).to_svg(xml) }
        end
      end

      def entity_label(xml, eprops)
        return if (entity.nil? || entity.name.nil? || entity.name.strip.empty?) && (child.content.nil? || child.content.strip.empty?)
        xml.foreignObject(text_bounds.to_h) do
          xml.table(xmlns: "http://www.w3.org/1999/xhtml", style: "height:#{text_bounds.height}px;width:#{text_bounds.width}px;") do
            xml.tr(style: "height:#{text_bounds.height}px;") do
              xml.td(class: "entity-name") do
                xml.div(class: "archimate-badge-spacer") unless eprops.badge.nil?
                xml.p(class: "entity-name") do
                  text_lines(entity.name || child.content).each do |line|
                    xml.text(line)
                    xml.br
                  end
                end
              end
            end
          end
        end
      end

      def text_lines(text)
        text.split(/[\r\n]/)
      end

      def entity_badge(xml, eprops)
        return if eprops.badge.nil?
        xml.use(
          badge_position(child.bounds)
            .to_h
            .merge("xlink:href" => eprops.badge)
        )
      end

      def badge_position(bounds)
        {
          x: bounds.x.to_i + bounds.width.to_i - 25,
          y: bounds.y.to_i + 5,
          width: 20,
          height: 15
        }
      end

      def entity_rect(xml, eprops)
        xml.use(
          child
            .bounds
            .to_h
            .merge("xlink:href" => eprops.shape, class: eprops.layer)
        )
      end

      def rect_path(xml, bounds, eprops)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: eprops.layer)
      end

      def rounded_rect_path(xml, bounds, eprops)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, rx: "5", ry:"5", class: eprops.layer)
      end

      def group_path(xml, bounds, eprops)
        group_header_height = 12
        xml.rect(x: bounds.left, y: bounds.top + group_header_height, width: bounds.width, height: bounds.height - group_header_height, class: eprops.layer)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: group_header_height, class: eprops.layer)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: group_header_height, class: "archimate-decoration")
      end

      def event_path(xml, bounds, eprops)
        xml.path(
          d:
            ScaledPath.new(
              "M 1 1 l 18 29 l -18 29 h 102 a 17 29 0 0 0 0 -58 z",
              bounds
            ).d,
         class: eprops.layer
        )
      end

      def service_path(xml, bounds, eprops)
        xml.path(
          d:
            ScaledPath.new(
              "M1 1 m 28 1 a 27.5 29 0 0 0 0 58 h 64 a 27.5 29 0 0 0 0 -58 z",
              bounds
            ).d,
          class: eprops.layer
        )
      end

      def value_path(xml, bounds, eprops)
        cx = bounds.width / 2.0
        cy = bounds.height / 2.0
        xml.ellipse(cx: cx, cy: cy, rx: cx - 1, ry: cy - 1, class: eprops.layer)
      end

      def component_path(xml, bounds, eprops)
        main_box_x = bounds.left + 21.0 / 2
        main_box_width = bounds.width - 21 / 2
        @text_bounds = DataModel::Bounds.new(
          x: main_box_x + 21 / 2,
          y: bounds.top + 1,
          width: bounds.width - 22,
          height: bounds.height - 2
        )
        xml.rect(x: main_box_x, y: bounds.top, width: main_box_width, height: bounds.height, class: eprops.layer)
        xml.rect(x: bounds.left, y: bounds.top + 10, width: "21", height: "13", class: eprops.layer)
        xml.rect(x: bounds.left, y: bounds.top + 30, width: "21", height: "13", class: eprops.layer)
        xml.rect(x: bounds.left, y: bounds.top + 10, width: "21", height: "13", class: "archimate-decoration")
        xml.rect(x: bounds.left, y: bounds.top + 30, width: "21", height: "13", class: "archimate-decoration")
      end

      def meaning_path(xml, bounds, eprops)
        xml.path(
          d:
            ScaledPath.new(
              "m64 50 c 10.032684,0.88695 19.756064,1.69123 32.056904,-1.990399 7.78769,-2.585368 13.84045,-6.631723 15.325,-14.525001 l -2.1243,-0.9298 c 12.08338,-6.64622 12.17498,-16.325 0.21788,-23.01969 -11.9571,-6.69469 -32.55996,-8.50001 -48.922378,-4.21636 -15.07176,-3.90873 -34.171306,-2.8786 -46.861284,2.60905 -12.689977,5.48764 -15.947034,14.12539 -7.812766,21.5177 -10.388939,9.088879 -2.212295,18.648042 9.683896,23.10671 14.30355,5.36094 31.495042,4.5785 46.145701,-2.1696 z",
              bounds
            ).d,
          class: eprops.layer
        )
      end

      def representation_path(xml, bounds, eprops)
        xml.path(
          d: [
            ["M", bounds.left, bounds.top],
            ["v", bounds.height - 8],
            ["c", 0.167 * bounds.width, 0.133 * bounds.height,
              0.336 * bounds.width, 0.133 * bounds.height,
              bounds.width * 0.508, 0
            ],
            ["c", 0.0161 * bounds.width, -0.0778 * bounds.height,
              0.322 * bounds.width, -0.0778 * bounds.height,
              bounds.width * 0.475, 0
            ],
            ["v", -(bounds.height - 8)],
            "z"
            ].flatten.join(" "),
          class: eprops.layer
        )
      end

      def node_path(xml, bounds, eprops)
        margin = 14
        node_box_height = bounds.height - margin
        node_box_width = bounds.width - margin
        @text_bounds = DataModel::Bounds.new(
          x: bounds.left + 1,
          y: bounds.top + margin + 1,
          width: node_box_width - 2,
          height: node_box_height - 2
        )
        xml.g(class: eprops.layer) do
          xml.path(
            d: [
              ["M", bounds.left, bounds.bottom],
              ["v", -node_box_height],
              ["l", margin, -margin],
              ["h", node_box_width],
              ["v", node_box_height],
              ["l", -margin, margin],
              "z"
            ].flatten.join(" ")
          )
          xml.path(
            d: [
              ["M", bounds.left, bounds.top + margin],
              ["l", margin, -margin],
              ["h", node_box_width],
              ["v", node_box_height],
              ["l", -margin, margin],
              ["v", -node_box_height],
              "z",
              ["M", bounds.right, bounds.top],
              ["l", -margin, margin]
            ].flatten.join(" "),
            class: "archimate-decoration"
          )
          xml.path(
            d: [
              ["M", bounds.left, bounds.top + margin],
              ["h", node_box_width],
              ["l", margin, -margin],
              ["M", bounds.left + node_box_width, bounds.bottom],
              ["v", -node_box_height]
            ].flatten.join(" "),
            style: "fill:none;stroke:inherit;"
          )
        end
      end

      def artifact_path(xml, bounds, eprops)
        margin = 18
        xml.g(class: eprops.layer) do
          xml.path(
            d: [
              ["M", bounds.left, bounds.top],
              ["h", bounds.width - margin],
              ["l", margin, margin],
              ["v", bounds.height - margin],
              ["h", -bounds.width],
              "z"
            ].flatten.join(" ")
          )
          xml.path(
            d: [
              ["M", bounds.right - margin, bounds.top],
              ["v", margin],
              ["h", margin],
              "z"
            ].flatten.join(" "),
            class: "archimate-decoration"
          )
        end
      end

      def motivation_path(xml, bounds, eprops)
        xml.path(
          d: ScaledPath.new(
              "m 11 1 h 98 l 10 10 v 38 l -10 10 h -98 l -10 -10 v -38 z",
              bounds
            ).d,
          class: eprops.layer
        )
      end

      def product_path(xml, bounds, eprops)
        xml.g(class: eprops.layer) do
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: eprops.layer)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: "8", class: "archimate-decoration")
        end
      end

      def data_path(xml, bounds, eprops)
        xml.g(class: eprops.layer) do
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: eprops.layer)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: "8", class: "archimate-decoration")
        end
      end

      def note_path(xml, bounds, eprops)
        xml.path(
          d: [
            ["m", bounds.left, bounds.top],
            ["h", bounds.width],
            ["v", bounds.height - 8],
            ["l", -8, 8],
            ["h", -(bounds.width - 8)],
            "z"
          ].flatten.join(" "),
          class: eprops.layer
        )
      end

      def group_attrs
        attrs = { id: @entity.id }
        # TODO: Transform only needed only for Archi file types
        attrs[:transform] = "translate(#{@bounds_offset.x}, #{@bounds_offset.y})" unless @bounds_offset.nil?
        attrs[:class] = "archimate-#{@entity.type}" if @entity.type || !@entity.type.empty?
        attrs
      end

      def entity_properties
        type = entity.type

        case type
        when "Business"
          EntityProperties.new(:rect_path, "archimate-business-background")
        when "Application"
          EntityProperties.new(:rect_path, "archimate-application-background")
        when "Technology"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background")
        when "Motivation"
          EntityProperties.new(:rect_path, "archimate-motivation-background")
        when "ImplementationandMigration"
          EntityProperties.new(:rect_path, "archimate-implementation-background")

        when "BusinessActor"
          EntityProperties.new(:rect_path, "archimate-business-background", "#archimate-actor-badge")
        when "BusinessRole"
          EntityProperties.new(:rect_path, "archimate-business-background", "#archimate-role-badge")
        when "BusinessCollaboration"
          EntityProperties.new(:rect_path, "archimate-business-background", "#archimate-collaboration-badge")
        when "BusinessInterface"
          EntityProperties.new(:rect_path, "archimate-business-background", "#archimate-interface-badge")
        when "Location"
          EntityProperties.new(:rect_path, "archimate-business-background", "#archimate-location-badge")
        when "BusinessProcess"
          EntityProperties.new(:rounded_rect_path, "archimate-business-background", "#archimate-process-badge")
        when "BusinessFunction"
          EntityProperties.new(:rounded_rect_path, "archimate-business-background", "#archimate-function-badge")
        when "BusinessInteraction"
          EntityProperties.new(:rounded_rect_path, "archimate-business-background", "#archimate-interaction-badge")
        when "BusinessEvent"
          EntityProperties.new(:event_path, "archimate-business-background")
        when "BusinessService"
          EntityProperties.new(:service_path, "archimate-business-background")
        when "BusinessObject"
          EntityProperties.new(:data_path, "archimate-business-background")
        when "Representation"
          EntityProperties.new(:representation_path, "archimate-business-background")
        when "Meaning"
          EntityProperties.new(:meaning_path, "archimate-business-background")
        when "Value"
          EntityProperties.new(:value_path, "archimate-business-background")
        when "Product"
          EntityProperties.new(:product_path, "archimate-business-background")
        when "Contract"
          EntityProperties.new(:data_path, "archimate-business-background")

        when "ApplicationComponent"
          EntityProperties.new(:component_path, "archimate-application-background")
        when "ApplicationCollaboration"
          EntityProperties.new(:rect_path, "archimate-application-background", "#archimate-collaboration-badge")
        when "ApplicationInterface"
          EntityProperties.new(:rect_path, "archimate-application-background", "#archimate-interface-badge")
        when "ApplicationFunction"
          EntityProperties.new(:rounded_rect_path, "archimate-application-background", "#archimate-function-badge")
        when "ApplicationInteraction"
          EntityProperties.new(:rounded_rect_path, "archimate-application-background", "#archimate-interaction-badge")
        when "ApplicationService"
          EntityProperties.new(:service_path, "archimate-application-background")
        when "DataObject"
          EntityProperties.new(:data_path, "archimate-application-background")

        when "Node"
          EntityProperties.new(:node_path, "archimate-infrastructure-background")
        when "Device"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background")
        when "SystemSoftware"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background", "#archimate-system_software-badge")
        when "InfrastructureInterface"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background", "#archimate-interface-badge")
        when "Network"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background", "#archimate-network-badge")
        when "CommunicationPath"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background", "#archimate-communication_path-badge")
        when "InfrastructureFunction"
          EntityProperties.new(:rounded_rect_path, "archimate-infrastructure-background", "#archimate-function-badge")
        when "InfrastructureService"
          EntityProperties.new(:service_path, "archimate-infrastructure-background")
        when "Artifact"
          EntityProperties.new(:artifact_path, "archimate-infrastructure-background")

        when "Stakeholder"
          EntityProperties.new(:motivation_path, "archimate-motivation-background", "#archimate-role-badge")
        when "Driver"
          EntityProperties.new(:motivation_path, "archimate-motivation-background", "#archimate-driver-badge")
        when "Assessment"
          EntityProperties.new(:motivation_path, "archimate-motivation-background", "#archimate-assessment-badge")
        when "Goal"
          EntityProperties.new(:motivation_path, "archimate-motivation-background", "#archimate-goal-badge")
        when "Requirement"
          EntityProperties.new(:motivation_path, "archimate-motivation2-background", "#archimate-requirement-badge")
        when "Constraint"
          EntityProperties.new(:motivation_path, "archimate-motivation2-background", "#archimate-constraint-badge")
        when "Principle"
          EntityProperties.new(:motivation_path, "archimate-motivation2-background", "#archimate-principle-badge")

        when "WorkPackage"
          EntityProperties.new(:rounded_rect_path, "archimate-implementation-background")
        when "Deliverable"
          EntityProperties.new(:representation_path, "archimate-implementation-background")
        when "Plateau"
          EntityProperties.new(:node_path, "archimate-implementation2-background", "#archimate-plateau-badge")
        when "Gap"
          EntityProperties.new(:representation_path, "archimate-implementation2-background", "#archimate-gap-badge")

        when "Junction", "AndJunction"
          EntityProperties.new(:rect_path, "archimate-junction-background", "#archimate-junction-badge")
        when "OrJunction"
          EntityProperties.new(:rect_path, "archimate-junction-background", "#archimate-or-junction-badge")

        when "archimate:Group", "Group"
          EntityProperties.new(:group_path, "archimate-group-background")
        when "archimate:Note", "Note"
          EntityProperties.new(:note_path, "archimate-note-background")
        when "archimate:SketchModelSticky", "SketchModelSticky"
          EntityProperties.new(:rect_path, "archimate-sticky-background")
        else
          EntityProperties.new(:rect_path, "archimate-default-background")
        end
      end
    end
  end
end
