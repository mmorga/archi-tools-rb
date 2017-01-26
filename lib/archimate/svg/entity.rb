# frozen_string_literal: true
module Archimate
  module Svg
    class Entity
      using StringRefinements

      attr_reader :child
      attr_reader :entity
      attr_reader :bounds_offset

      EntityProperties = Struct.new(:shape, :layer, :badge, :decoration)

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
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", "#archimate-process-badge")
        when "BusinessFunction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-business-background", "#archimate-function-badge")
        when "BusinessInteraction"
          EntityProperties.new("#archimate-rounded-rect-path", "archimate-business-background", "#archimate-interaction-badge")
        when "BusinessEvent"
          EntityProperties.new("#archimate-event-path", "archimate-business-background")
        when "BusinessService"
          EntityProperties.new("#archimate-service-path", "archimate-business-background")
        when "BusinessObject"
          EntityProperties.new("#archimate-data-path", "archimate-business-background", nil, "#archimate-header-flag")
        when "Representation"
          EntityProperties.new("#archimate-representation-path", "archimate-business-background")
        when "Meaning"
          EntityProperties.new("#archimate-meaning-path", "archimate-business-background")
        when "Value"
          EntityProperties.new("#archimate-value-path", "archimate-business-background")
        when "Product"
          EntityProperties.new("#archimate-rect-path", "archimate-business-background", nil, "#archimate-product-flag")
        when "Contract"
          EntityProperties.new("#archimate-data-path", "archimate-business-background", nil, "#archimate-header-flag")

        when "ApplicationComponent"
          EntityProperties.new("#archimate-component-path", "archimate-application-background", nil, "#archimate-component-flag")
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
          EntityProperties.new("#archimate-data-path", "archimate-application-background", nil, "#archimate-header-flag")

        when "Node"
          EntityProperties.new("#archimate-node-path", "archimate-infrastructure-background", nil, "#archimate-node-flag")
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
          EntityProperties.new("#archimate-artifact-path", "archimate-infrastructure-background", nil, "#archimate-artifact-flag")

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
          EntityProperties.new("#archimate-node-path", "archimate-implementation2-background", "#archimate-plateau-badge", "#archimate-node-flag")
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
