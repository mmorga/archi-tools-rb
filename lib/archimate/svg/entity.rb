# frozen_string_literal: true
module Archimate
  module Svg
    class Entity
      attr_reader :child
      attr_reader :entity
      attr_reader :bounds_offset
      attr_reader :text_bounds
      attr_reader :badge_bounds

      # shape (+ class: layer)
      #   badge (shape knows badge position)
      #   text (shape knows region for text)
      EntityProperties = Struct.new(:shape, :layer, :badge)

      def initialize(child, bounds_offset)
        @child = child
        @text_bounds = child.bounds.reduced_by(2)
        @bounds_offset = bounds_offset
        @entity = @child.element || @child
        @text_align = nil
        @badge_bounds = child.bounds.with(
          x: child.bounds.right - 25,
          y: child.bounds.top + 5,
          width: 20,
          height: 20
        )
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
                xml.p(class: "entity-name", style: text_style) do
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
        text.tr("\r\n", "\n").split(/[\r\n]/)
      end

      def entity_badge(xml, eprops)
        return if eprops.badge.nil?
        xml.use(
          badge_bounds
            .to_h
            .merge("xlink:href" => eprops.badge)
        )
      end

      def shape_style
        style = child.style
        return "" if style.nil?
        {
          "fill": style.fill_color&.to_rgba,
          "stroke": style.line_color&.to_rgba,
          "stroke-width": style.line_width
        }.delete_if { |key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};"}
          .join("")
      end

      def text_style
        style = child.style || DataModel::Style.new
        {
          "fill": style.font_color&.to_rgba,
          "color": style.font_color&.to_rgba,
          "font-family": style.font&.name,
          "font-size": style.font&.size,
          "text-align": style.text_align || @text_align
        }.delete_if { |key, value| value.nil? }
          .map { |key, value| "#{key}:#{value};"}
          .join("")
      end

      def rect_path(xml, bounds, eprops)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: eprops.layer, style: shape_style)
      end

      def circle_path(xml, bounds, eprops)
        xml.circle(cx: bounds.left + bounds.width / 2.0, cy: bounds.top + bounds.height / 2.0, r: bounds.width / 2.0, class: eprops.layer, style: shape_style)
      end

      def rounded_rect_path(xml, bounds, eprops)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, rx: "5", ry:"5", class: eprops.layer)
      end

      def group_path(xml, bounds, eprops)
        group_header_height = 21
        xml.rect(x: bounds.left, y: bounds.top + group_header_height, width: bounds.width, height: bounds.height - group_header_height, class: eprops.layer, style: shape_style)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: group_header_height, class: eprops.layer, style: shape_style)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: group_header_height, class: "archimate-decoration")
        @text_bounds = bounds.with(height: group_header_height)
        @text_align = "left"
      end

      def event_path(xml, bounds, eprops)
        notch_x = 18
        notch_height = bounds.height / 2.0
        event_width = bounds.width * 0.85
        rx = 17
        xml.path(
          d: [
            "M", bounds.left, bounds.top,
            "l", notch_x, notch_height,
            "l", -notch_x, notch_height,
            "h", event_width,
            "a", rx, notch_height, 0, 0, 0, 0, -bounds.height,
            "z"
          ].flatten.join(" "),
         class: eprops.layer, style: shape_style
        )
      end

      def service_path(xml, bounds, eprops)
        @text_bounds = bounds.with(
          x: bounds.left + 5,
          y: bounds.top + 5,
          width: bounds.width - 10,
          height: bounds.height - 10
        )
        xml.rect(
          x: bounds.left,
          y: bounds.top,
          width: bounds.width,
          height: bounds.height,
          rx: bounds.height / 2.0,
          ry: bounds.height / 2.0,
          class: eprops.layer,
          style: shape_style
        )
      end

      def value_path(xml, bounds, eprops)
        cx = bounds.left + bounds.width / 2.0
        rx = bounds.width / 2.0 - 1
        cy = bounds.top + bounds.height / 2.0
        ry = bounds.height / 2.0 - 1
        xml.ellipse(cx: cx, cy: cy, rx: rx, ry: ry, class: eprops.layer, style: shape_style)
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
        xml.rect(x: main_box_x, y: bounds.top, width: main_box_width, height: bounds.height, class: eprops.layer, style: shape_style)
        xml.rect(x: bounds.left, y: bounds.top + 10, width: "21", height: "13", class: eprops.layer, style: shape_style)
        xml.rect(x: bounds.left, y: bounds.top + 30, width: "21", height: "13", class: eprops.layer, style: shape_style)
        xml.rect(x: bounds.left, y: bounds.top + 10, width: "21", height: "13", class: "archimate-decoration")
        xml.rect(x: bounds.left, y: bounds.top + 30, width: "21", height: "13", class: "archimate-decoration")
      end

      def meaning_path(xml, bounds, eprops)
        pts = [
          Point.new(bounds.left + bounds.width * 0.04, bounds.top + bounds.height * 0.5),
          Point.new(bounds.left + bounds.width * 0.5, bounds.top + bounds.height * 0.12),
          Point.new(bounds.left + bounds.width * 0.94, bounds.top + bounds.height * 0.55),
          Point.new(bounds.left + bounds.width * 0.53, bounds.top + bounds.height * 0.87)
        ]
        xml.path(
          d: [
            "M", pts[0].x, pts[0].y,
            "C", pts[0].x - bounds.width * 0.15, pts[0].y - bounds.height * 0.32,
                 pts[1].x - bounds.width * 0.3, pts[1].y - bounds.height * 0.15,
                 pts[1].x, pts[1].y,
            "C", pts[1].x + bounds.width * 0.29, pts[1].y - bounds.height * 0.184,
                 pts[2].x + bounds.width * 0.204, pts[2].y - bounds.height * 0.304,
                 pts[2].x, pts[2].y,
            "C", pts[2].x + bounds.width * 0.028, pts[2].y + bounds.height * 0.295,
                 pts[3].x + bounds.width * 0.156, pts[3].y + bounds.height * 0.088,
                 pts[3].x, pts[3].y,
            "C", pts[3].x - bounds.width * 0.279, pts[3].y + bounds.height * 0.326,
                 pts[0].x - bounds.width * 0.164, pts[0].y + bounds.height * 0.314,
                 pts[0].x, pts[0].y
          ].flatten.join(" "),
          class: eprops.layer, style: shape_style
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
          class: eprops.layer, style: shape_style
        )
      end

      def node_path(xml, bounds, eprops)
        margin = 14
        @badge_bounds = DataModel::Bounds.new(
          x: bounds.right - margin - 25,
          y: bounds.top + margin + 5,
          width: 20,
          height: 20
        )
        node_box_height = bounds.height - margin
        node_box_width = bounds.width - margin
        @text_bounds = DataModel::Bounds.new(
          x: bounds.left + 1,
          y: bounds.top + margin + 1,
          width: node_box_width - 2,
          height: node_box_height - 2
        )
        xml.g(class: eprops.layer, style: shape_style) do
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
        xml.g(class: eprops.layer, style: shape_style) do
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
        margin = 10
        width = bounds.width - margin * 2
        height = bounds.height - margin * 2
        xml.path(
          d: [
            ["M", bounds.left + margin, bounds.top],
            ["h", width],
            ["l", margin, margin],
            ["v", height],
            ["l", -margin, margin],
            ["h", -width],
            ["l", -margin, -margin],
            ["v", -height],
            "z"
          ].flatten.join(" "),
          class: eprops.layer,
          style: shape_style
        )
      end

      def product_path(xml, bounds, eprops)
        xml.g(class: eprops.layer) do
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: eprops.layer, style: shape_style)
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width / 2.0, height: "8", class: "archimate-decoration")
        end
      end

      def data_path(xml, bounds, eprops)
        xml.g(class: eprops.layer) do
          xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, class: eprops.layer, style: shape_style)
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
          class: eprops.layer,
          style: shape_style
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
          EntityProperties.new(:node_path, "archimate-infrastructure-background", "#archimate-device-badge")
        when "SystemSoftware"
          EntityProperties.new(:rect_path, "archimate-infrastructure-background", "#archimate-system-software-badge")
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

        when "Junction"
          EntityProperties.new(:circle_path, "archimate-junction-background")
        when "AndJunction"
          EntityProperties.new(:rect_path, "archimate-junction-background")
        when "OrJunction"
          EntityProperties.new(:rect_path, "archimate-or-junction-background")

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
