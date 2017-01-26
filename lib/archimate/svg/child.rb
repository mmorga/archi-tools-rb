# frozen_string_literal: true
module Archimate
  module Svg
    class Child
      attr_reader :todos
      attr_reader :child

      def initialize(child, aio)
        @child = child
        @aio = aio
        @todos = Hash.new(0)
      end

      # TODO: This is really render an element (and it's children) into the given svg
      # The info needed to render is contained in the child with the exception of
      # any offset needed. So this will need to be included in the recursive drawing of children
      def render_elements(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          draw_element(xml, child)
        end
        svg
      end

      def render_connections(svg)
        Nokogiri::XML::Builder.with(svg) do |xml|
          draw_connection(xml, child)
        end
        svg
      end

      def draw_element_rect(xml, element, ctx)
        return if element.is_a?(Archimate::DataModel::Model) # TODO: why is this happening?
        x = ctx["x"].to_i + ctx["width"].to_i - 25
        y = ctx["y"].to_i + 5
        case element.type
        when "ApplicationService", "BusinessService", "InfrastructureService"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "27.5", ry: "27.5")
        when "ApplicationInterface", "BusinessInterface"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
          xml.use(x: "0", y: "0", width: "20", height: "15",
                  transform: "translate(#{x}, #{y})",
                  "xlink:href" => "#interface-badge")
        when "BusinessActor"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
          xml.use(x: "0", y: "0", width: "20", height: "15",
                  transform: "translate(#{x}, #{y})",
                  "xlink:href" => "#actor-badge")
        when "ApplicationInteraction"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "10", ry: "10")
          xml.use(x: "0", y: "0", width: "20", height: "15",
                  transform: "translate(#{x}, #{y})",
                  "xlink:href" => "#interaction-badge")
        when "ApplicationCollaboration", "BusinessCollaboration"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
          xml.use(x: "0", y: "0", width: "20", height: "15",
                  transform: "translate(#{x}, #{y})",
                  "xlink:href" => "#collaboration-badge")
        when "ApplicationFunction", "BusinessFunction", "InfrastructureFunction"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"], rx: "10", ry: "10")
          xml.use(x: "0", y: "0", width: "20", height: "15",
                  transform: "translate(#{x}, #{y})",
                  "xlink:href" => "#function-badge")
        when "ApplicationComponent"
          xml.rect(x: ctx["x"].to_i + 10, y: ctx["y"], width: ctx["width"].to_i - 10, height: ctx["height"])
          xml.use(x: "0", y: "0", width: "23", height: "44", class: "topbox",
                  transform: "translate(#{ctx['x']}, #{ctx['y']})",
                  "xlink:href" => "#component-knobs")
        when "DataObject"
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: "14", class: "topbox")
        else
          # puts "TODO: implement #{el_type}"
          # puts element
          # $todos[element&.type] += 1
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
        end
      end

      def element_text_bounds(element, ctx)
        return Archimate::DataModel::Bounds.zero if element.is_a?(Archimate::DataModel::Model) # TODO: why is this happening?
        case element.type
        when "ApplicationService"
          ctx.with(x: (ctx.x || 0) + 10, y: (ctx.y || 0), width: ctx.width - 20, height: ctx.height)
        when "DataObject"
          ctx.with(x: (ctx.x || 0) + 5, y: (ctx.y || 0) + 14, width: ctx.width - 10, height: ctx.height)
        else
          ctx.with(x: (ctx.x || 0) + 5, y: (ctx.y || 0), width: ctx.width - 30, height: ctx.height)
        end
      end

      def draw_element(xml, child, context = nil)
        Entity.new(child, context).to_svg(xml)
        # element = child.element
        # group_class = element.is_a?(Archimate::DataModel::Model) ? "" : element&.type
        # group_attrs = { id: child.archimate_element, class: group_class }
        # group_attrs[:transform] = "translate(#{context['x']}, #{context['y']})" unless context.nil? # TODO: Needed only for archi file types
        # xml.g(group_attrs) do
        #   xml.title { xml.text child.name }
        #   xml.desc { xml.text(child.documentation.map(&:text).join("\n\n")) }
        #   draw_element_rect(xml, element || child, child.bounds)
        #   draw_element_label(xml, element || child, child.bounds)
        #   child.children.each { |c| draw_element(xml, c, child.bounds) }
        # end
      end

      def draw_element_label(xml, entity, bounds)
        return if entity.nil? || entity.name.nil? || entity.name.strip.empty?
        text_bounds = element_text_bounds(entity, bounds)
        xml.foreignObject(text_bounds.to_h) do
          xml.tr(xmlns: "http://www.w3.org/1999/xhtml", style: "height:#{text_bounds.height}px;") do
            xml.td(class: "entity-name") do
              xml.p(class: "entity-name") { xml.text entity.name }
            end
          end
        end
      end

      def pos_element(element)
        offset = Archimate::DataModel::Bounds.zero
        return offset if element.nil?
        el = element.parent
        while el.respond_to?(:bounds) && el.bounds
          bounds = el.bounds
          offset = offset.with(x: offset.x + bounds.x, y: offset.y + bounds.y)
          el = el.parent
        end
        offset
      end

      def draw_connection(xml, child, _context = nil)
        child.source_connections.each do |src_conn|
          source = src_conn.in_model.lookup(src_conn.source)
          next unless source
          target = src_conn.in_model.lookup(src_conn.target)
          next unless target
          src_offset = pos_element(source)
          target_offset = pos_element(target)
          next if source&.ancestors&.include?(target)
          next if target&.ancestors&.include?(source)
          rel = src_conn.relationship || ""
          startx = src_offset.x + (source.bounds.x || 0) + (source.bounds.width / 2)
          starty = src_offset.y + (source.bounds.y || 0) + (source.bounds.height / 2)
          endx = target_offset.x + (target.bounds.x || 0) + (target.bounds.width / 2)
          endy = target_offset.y + (target.bounds.y || 0) + (target.bounds.height / 2)
          xml.path(d: "M #{startx} #{starty} L #{endx} #{endy}", class: rel) do |path|
            path.title do |title|
              source_element = source.element&.name || ""
              target_element = target.element&.name || ""
              title.text "#{rel}: #{source_element} to #{target_element}" unless source_element.empty? || target_element.empty?
            end
          end
        end
      end
    end
  end
end
