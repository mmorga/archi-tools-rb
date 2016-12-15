# frozen_string_literal: true

begin
  require 'RMagick'
rescue LoadError
  $stderr.puts "SVG production depends on ImageMagick and the RMagick gem. Install ImageMagick from http://www.imagemagick.org/ and 'gem install rmagick'"
end

module Archimate
  module Cli
    class Svger
      attr_reader :todos

      XSI = "http://www.w3.org/2001/XMLSchema-instance"

      BADGES = {
        "ApplicationInterface" => "#interface-badge",
        "ApplicationInteraction" => "#interaction-badge",
        "ApplicationCollaboration" => "#collaboration-badge",
        "ApplicationFunction" => "#function-badge",
        "BusinessActor" => "#actor-badge"
      }.freeze

      def self.export_svgs(archi_file, aio)
        model = Archimate.read(archi_file, aio)
        new(model, aio).export_svgs
      end

      def initialize(model, aio)
        @model = model
        @aio = aio
        reset_min_max
        @todos = Hash.new(0)
      end

      # TODO: refactor this to a font/style class
      def text_width(text)
        draw = Magick::Draw.new
        draw.font = "/System/Library/Fonts/LucidaGrande.ttc"
        draw.pointsize = 12
        draw.get_type_metrics(text).width
      end

      # TODO: refactor this to a font/style class
      def fit_text_to_width(text, width)
        # t = Text.new
        results = []
        words = text.split(" ")
        candidate = words.shift
        until words.empty?
          next_word = words.shift
          new_candidate = candidate + " " + next_word
          # if t.width(new_candidate) > width
          if text_width(new_candidate) > width
            results << candidate
            candidate = next_word
          else
            candidate = new_candidate
          end
        end
        results << candidate
        results
      end

      def draw_element_rect(xml, element, ctx)
        return if element.is_a?(Archimate::DataModel::Model) #TODO: why is this happening?
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
        return Archimate::DataModel::Bounds.zero if element.is_a?(Archimate::DataModel::Model) #TODO: why is this happening?
        case element.type
        when "ApplicationService"
          ctx.with(x: ctx.x + 10, y: ctx.y, width: ctx.width - 20, height: ctx.height)
        when "DataObject"
          ctx.with(x: ctx.x + 5, y: ctx.y + 14, width: ctx.width - 10, height: ctx.height)
        else
          ctx.with(x: ctx.x + 5, y: ctx.y, width: ctx.width - 30, height: ctx.height)
        end
      end

      def reset_min_max
        @min_x = 0
        @max_x = 100
        @min_y = 0
        @max_y = 100
      end

      def compute_drawing_bounds(b)
        @min_x = b.x if b.x < @min_x
        @max_x = (b.x + b.width) if (b.x + b.width) > @max_x
        @min_y = b.y if b.y < @min_y
        @max_y = b.y + b.height if b.y + b.height > @max_y
      end

      def draw_element(xml, child, context = nil)
        bounds = child.bounds
        compute_drawing_bounds(bounds)
        element_id = child.archimate_element
        element = @model.lookup(element_id)
        return if element.nil?
        group_class = element.is_a?(Archimate::DataModel::Model) ? "" : element&.type
        group_attrs = { id: element_id, class: group_class }
        group_attrs[:transform] = "translate(#{context['x']}, #{context['y']})" unless context.nil?
        xml.g(group_attrs) do
          draw_element_rect(xml, element, bounds)
          text_bounds = element_text_bounds(element, bounds)
          y = text_bounds.y
          x = bounds.x + (bounds.width / 2)
          content = element.name || ""
          fit_text_to_width(content, text_bounds.width).each do |line|
            y += 17
            xml.text_(x: x, y: y, "text-anchor" => :middle) do
              xml.text line
            end
          end
          child.children.each { |c| draw_element(xml, c, bounds) }
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

      def line_points_for_bounds(a, b)
        # look at x & y separately
        # if a.x_range overlaps b.x_range
        #   result a&b.x = midpount of a.x_range intersection b.x_range
        # else if a.x_range < b.x_range
        #   result a.x = max_x(a.x_range), b.x = min_x(a.x_range)
        # else inverse
        # Same for y
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
          startx = src_offset.x + source.bounds.x + (source.bounds.width / 2)
          starty = src_offset.y + source.bounds.y + (source.bounds.height / 2)
          endx = target_offset.x + target.bounds.x + (target.bounds.width / 2)
          endy = target_offset.y + target.bounds.y + (target.bounds.height / 2)
          xml.path(d: "M #{startx} #{starty} L #{endx} #{endy}", class: rel) do |path|
            path.title do |title|
              source_element = source.element&.name || ""
              target_element = target.element&.name || ""
              title.text "#{rel}: #{source_element} to #{target_element}" unless source_element.empty? || target_element.empty?
            end
          end
        end
      end

      def svg_template
        Nokogiri::XML::Document.parse(File.read(File.join(File.dirname(__FILE__), "svg_template.svg")))
      end

      def export_svgs
        @model.diagrams.each do |diagram|
          reset_min_max
          svg_doc = svg_template
          svg = svg_doc.at_css("svg")

          name = diagram.name
          # TODO: use output message helper puts name
          diagram.children.each do |child|
            Nokogiri::XML::Builder.with(svg) do |xml|
              draw_element(xml, child)
            end
          end

          diagram.children.each do |child|
            Nokogiri::XML::Builder.with(svg) do |xml|
              draw_connection(xml, child)
            end
          end

          x = @min_x - 10
          y = @min_y - 10
          width = @max_x - @min_x + 10
          height = @max_y - @min_y + 10
          svg.set_attribute(:x, x)
          svg.set_attribute(:y, y)
          svg.set_attribute(:width, width)
          svg.set_attribute(:height, height)
          svg.set_attribute("viewBox", "#{x} #{y} #{width} #{height}")

          File.open(File.join(@aio.output_dir, "#{name}.svg"), "wb") do |f|
            f.write(svg_doc.to_xml(encoding: 'UTF-8', indent: 2))
          end
        end

        # puts "\n\n"
        # todos.keys.sort.each { |el| puts "#{el}: #{todos[el]}" }
      end
    end
  end
end
