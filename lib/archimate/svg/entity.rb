# frozen_string_literal: true
module Archimate
  module Svg
    class Entity
      using StringRefinements

      attr_reader :child
      attr_reader :entity
      attr_reader :bounds_offset

      # shape (+ class: layer)
      #   badge (shape knows badge position)
      #   text (shape knows region for text)
      EntityProperties = Struct.new(:shape, :layer, :badge)

      def initialize(child, bounds_offset)
        @child = child
        @bounds_offset = bounds_offset
        @entity = @child.element || @child
        raise "Hell!" if @entity.nil?
      end

      def to_svg(xml)
        eprops = entity_properties
        xml.g(group_attrs) do
          xml.title { xml.text @entity.name } unless @entity.name.nil? || @entity.name.empty?
          xml.desc { xml.text(@entity.documentation.map(&:text).join("\n\n")) } unless @entity.documentation.empty?
          entity_rect(xml, eprops)
          entity_badge(xml, eprops)
          entity_label(xml, eprops)
          child.children.each { |c| Entity.new(c, child.bounds).to_svg(xml) }
        end
      end

      # def entity_text_bounds(bounds, eprops)
      #   return Archimate::DataModel::Bounds.zero if element.is_a?(Archimate::DataModel::Model) # TODO: why is this happening?
      #   case element.type
      #   when "ApplicationService"
      #     ctx.with(x: (ctx.x || 0) + 10, y: (ctx.y || 0), width: ctx.width - 20, height: ctx.height)
      #   when "DataObject"
      #     ctx.with(x: (ctx.x || 0) + 5, y: (ctx.y || 0) + 14, width: ctx.width - 10, height: ctx.height)
      #   else
      #     ctx.with(x: (ctx.x || 0) + 5, y: (ctx.y || 0), width: ctx.width - 30, height: ctx.height)
      #   end
      # end

      def entity_label(xml, _eprops)
        return if (entity.nil? || entity.name.nil? || entity.name.strip.empty?) && (child.content.nil? || child.content.strip.empty?)
        text_bounds = child.bounds # eprops.text_bounds
        xml.foreignObject(text_bounds.to_h) do
          xml.table(xmlns: "http://www.w3.org/1999/xhtml", style: "height:#{text_bounds.height}px;width:#{text_bounds.width}px;") do
            xml.tr(style: "height:#{text_bounds.height}px;") do
              xml.td(class: "entity-name") do
                xml.div(class: "archimate-badge-spacer")
                xml.p(class: "entity-name") { xml.text(entity.name || child.content) }
              end
            end
          end
        end
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

      def rect(xml, bounds)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height)
      end

      def rounded_rect(xml, bounds)
        xml.rect(x: bounds.left, y: bounds.top, width: bounds.width, height: bounds.height, rx: "5", ry:"5")
      end

      def event_path(xml, bounds)
        xml.path(d: "M 1 1 l 18 29 l -18 29 h 102 a 17 29 0 0 0 0 -58 z", style: "fill:inherit;stroke:inherit")
      end

      def service_path(xml, bounds)
        xml.path(d: "M28 1 a 27.5 29 0 0 0 0 58 h 64 a 27.5 29 0 0 0 0 -58 z", style: "fill:inherit;stroke:inherit")
      end

      def value_path(xml, bounds)
        cx = bounds.width / 2.0
        cy = bounds.height / 2.0
        xml.ellipse(cx: cx, cy: cy, rx: cx - 1, ry: cy - 1, style: "fill:inherit;stroke:inherit")
      end

      def component_path(xml, bounds)
        main_box_x = 0.075 * bounds.width
        main_box_width = bounds.width - main_box_x
        xml.rect(x: main_box_x, y: bounds.y, width: main_box_width, height: bounds.height, style: "fill:inherit;stroke:inherit;stroke-width:inherit;")
        xml.rect(x: bounds.left, y: bounds.top + 10, width: "21", height: "13", class: "archimate-decoration", style: "fill:inherit;stroke:inherit;stroke-width:inherit;")
        xml.rect(x: bounds.left, y: bounds.top + 30, width: "21", height: "13", class: "archimate-decoration", style: "fill:inherit;stroke:inherit;stroke-width:inherit;")
        xml.rect(x: bounds.left, y: bounds.top + 10, width: "21", height: "13", class: "archimate-decoration", style: "fill:rgba(0,0,0,0.2);stroke:inherit;stroke-width:inherit;")
        xml.rect(x: bounds.left, y: bounds.top + 30, width: "21", height: "13", class: "archimate-decoration", style: "fill:rgba(0,0,0,0.2);stroke:inherit;stroke-width:inherit;")
      end

      def meaning_path(xml, bounds)
        xml.path(d: "m64 50 c 10.032684,0.88695 19.756064,1.69123 32.056904,-1.990399 7.78769,-2.585368 13.84045,-6.631723 15.325,-14.525001 l -2.1243,-0.9298 c 12.08338,-6.64622 12.17498,-16.325 0.21788,-23.01969 -11.9571,-6.69469 -32.55996,-8.50001 -48.922378,-4.21636 -15.07176,-3.90873 -34.171306,-2.8786 -46.861284,2.60905 -12.689977,5.48764 -15.947034,14.12539 -7.812766,21.5177 -10.388939,9.088879 -2.212295,18.648042 9.683896,23.10671 14.30355,5.36094 31.495042,4.5785 46.145701,-2.1696 z", style: "fill:inherit;stroke:inherit")
      end

      def representation_path(xml, bounds)
        xml.path(d: "m 1 1 v 52 c 20  8 40.3333 8 61  0 c 19.3333 -4.6667 38.6667 -4.6667 57  0 v -52 z", style: "fill:inherit;stroke:inherit")
      end

      def node_path(xml, bounds)
        xml.path(d: "M1 59 v -44 l 14 -14 h 104 v 44 l -14 14 z", style: "fill:inherit;stroke:inherit")
        xml.path(d: "M1 15 l 14 -14 h 104 v 44 l -14 14 v -44 z M 119 1 l -14 14", class: "archimate-decoration", style: "fill:rgba(0,0,0,0.2);stroke:none")
        xml.path(d: "M1 15 h 104 l 14 -14 M 105 59 v -44", style: "fill:none;stroke:inherit;")
      end

      def artifact_path(xml, bounds)
        xml.path(d: "m 1 1 h 100 l 18 18 v 40 h -118 z", style: "fill:inherit;stroke:inherit")
        xml.path(d: "m 101 1 v 18 h 18 z", class: "archimate-decoration", style: "fill:rgba(0,0,0,0.2);stroke:inherit")
      end

      def motivation_path(xml, bounds)
        xml.path(d: "m 11 1 h 98 l 10 10 v 38 l -10 10 h -98 l -10 -10 v -38 z", style: "fill:inherit;stroke:inherit")
      end

      def product_path(xml, bounds)
        xml.rect(x: "1", y: "1", width: "118", height: "58", style: "fill:inherit;stroke:inherit;stroke-width:inherit;")
        xml.rect(x: "1", y: "1", width: "59", height: "8", class: "archimate-decoration", style: "fill:rgba(0,0,0,0.2);stroke:inherit;stroke-width:inherit;")
      end

      def data_path(xml, bounds)
        xml.rect(x: "1", y: "1", width: "118", height: "58", style: "fill:inherit;stroke:inherit;stroke-width:inherit;")
        xml.rect(x: "1", y: "1", width: "118", height: "8", class: "archimate-decoration", style: "fill:rgba(0,0,0,0.2);stroke:inherit;stroke-width:inherit;")
      end

      # TODO:
      def note_path(xml, bounds)
      end

      # TODO:
      def group_path(xml, bounds)
      end

      def group_attrs
        attrs = { id: @entity.id }
        # TODO: Transform only needed only for Archi file types
        attrs[:transform] = "translate(#{@bounds_offset.x}, #{@bounds_offset.y})" unless @bounds_offset.nil?
        attrs
      end

      def entity_properties
        type = entity.type

        case type
        when "Business"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background")
        when "Application"
          EntityProperties.new("#archimate-rect-path", "archimate-application-background")
        when "Technology"
          EntityProperties.new("#archimate-rect-path", "archimate-infrastructure-background")
        when "Motivation"
          EntityProperties.new("#archimate-rect-path", "archimate-motivation-background")
        when "ImplementationandMigration"
          EntityProperties.new("#archimate-rect-path", "archimate-implementation-background")

        when "BusinessActor"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", "#archimate-actor-badge")
        when "BusinessRole"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", "#archimate-role-badge")
        when "BusinessCollaboration"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", "#archimate-collaboration-badge")
        when "BusinessInterface"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", "#archimate-interface-badge")
        when "Location"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", "#archimate-location-badge")
        when "BusinessProcess"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-business-background", "#archimate-process-badge")
        when "BusinessFunction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-business-background", "#archimate-function-badge")
        when "BusinessInteraction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-business-background", "#archimate-interaction-badge")
        when "BusinessEvent"
          EntityProperties.new("#archimate-event-path", "archimate-business-background")
        when "BusinessService"
          EntityProperties.new("#archimate-service-path", "archimate-business-background")
        when "BusinessObject"
          EntityProperties.new("#archimate-data-path", "archimate-business-background")
        when "Representation"
          EntityProperties.new("#archimate-representation-path", "archimate-business-background")
        when "Meaning"
          EntityProperties.new("#archimate-meaning-path", "archimate-business-background")
        when "Value"
          EntityProperties.new("#archimate-value-path", "archimate-business-background")
        when "Product"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background")
        when "Contract"
          EntityProperties.new("#archimate-data-path", "archimate-business-background")

        when "ApplicationComponent"
          EntityProperties.new("#archimate-component-path", "archimate-application-background")
        when "ApplicationCollaboration"
          EntityProperties.new("#archimate-rect-path", "archimate-application-background", "#archimate-collaboration-badge")
        when "ApplicationInterface"
          EntityProperties.new("#archimate-rect-path", "archimate-application-background", "#archimate-interface-badge")
        when "ApplicationFunction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-application-background", "#archimate-function-badge")
        when "ApplicationInteraction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-application-background", "#archimate-interaction-badge")
        when "ApplicationService"
          EntityProperties.new("#archimate-service-path", "archimate-application-background")
        when "DataObject"
          EntityProperties.new("#archimate-data-path", "archimate-application-background")

        when "Node"
          EntityProperties.new("#archimate-node-path", "archimate-infrastructure-background")
        when "Device"
          EntityProperties.new("#archimate-rect-path", "archimate-infrastructure-background")
        when "SystemSoftware"
          EntityProperties.new("#archimate-rect-path", "archimate-infrastructure-background", "#archimate-system_software-badge")
        when "InfrastructureInterface"
          EntityProperties.new("#archimate-rect-path", "archimate-infrastructure-background", "#archimate-interface-badge")
        when "Network"
          EntityProperties.new("#archimate-rect-path", "archimate-infrastructure-background", "#archimate-network-badge")
        when "CommunicationPath"
          EntityProperties.new("#archimate-rect-path", "archimate-infrastructure-background", "#archimate-communication_path-badge")
        when "InfrastructureFunction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-infrastructure-background", "#archimate-function-badge")
        when "InfrastructureService"
          EntityProperties.new("#archimate-service-path", "archimate-infrastructure-background")
        when "Artifact"
          EntityProperties.new("#archimate-artifact-path", "archimate-infrastructure-background")

        when "Stakeholder"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation-background", "#archimate-role-badge")
        when "Driver"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation-background", "#archimate-driver-badge")
        when "Assessment"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation-background", "#archimate-assessment-badge")
        when "Goal"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation-background", "#archimate-goal-badge")
        when "Requirement"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation2-background", "#archimate-requirement-badge")
        when "Constraint"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation2-background", "#archimate-constraint-badge")
        when "Principle"
          EntityProperties.new("#archimate-motivation-path", "archimate-motivation2-background", "#archimate-principle-badge")

        when "WorkPackage"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-implementation-background")
        when "Deliverable"
          EntityProperties.new("#archimate-representation-path", "archimate-implementation-background")
        when "Plateau"
          EntityProperties.new("#archimate-node-path", "archimate-implementation2-background", "#archimate-plateau-badge")
        when "Gap"
          EntityProperties.new("#archimate-representation-path", "archimate-implementation2-background", "#archimate-gap-badge")

        when "Junction"
          EntityProperties.new("#archimate-rect-path", "archimate-default-background", "#archimate-junction-badge")
        when "OrJunction"
          EntityProperties.new("#archimate-rect-path", "archimate-default-background", "#archimate-or_junction-badge")
        when "AndJunction"
          EntityProperties.new("#archimate-rect-path", "archimate-default-background", "#archimate-junction-badge")

        when "archimate:Group", "Group"
          EntityProperties.new("#archimate-rect-path", "archimate-default-background")
        when "archimate:Note", "Note"
          EntityProperties.new("#archimate-rect-path", "archimate-default-background")
        when "archimate:SketchModelSticky", "SketchModelSticky"
          EntityProperties.new("#archimate-rect-path", "archimate-default-background")
        else
          EntityProperties.new("#archimate-rect-path", "archimate-default-background")
        end
      end
    end
  end
end
