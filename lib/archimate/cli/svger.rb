# frozen_string_literal: true
require 'RMagick'

module Archimate
  module Cli
    class Svger
      XSI = "http://www.w3.org/2001/XMLSchema-instance"
      Struct.new("Bounds", :x, :y, :width, :height)

      def initialize
        reset_min_max
      end

      def text_width(text)
        draw = Magick::Draw.new
        draw.font = "/System/Library/Fonts/LucidaGrande.ttc"
        draw.pointsize = 12
        draw.get_type_metrics(text).width
      end

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

      def element_type(el)
        el.attribute_with_ns("type", XSI).value[10..-1]
      end

      $todos = Hash.new(0)

      BADGES = {
        "ApplicationInterface" => "#interface-badge",
        "ApplicationInteraction" => "#interaction-badge",
        "ApplicationCollaboration" => "#collaboration-badge",
        "ApplicationFunction" => "#function-badge",
        "BusinessActor" => "#actor-badge"
      }.freeze

      def draw_element_rect(xml, element, ctx)
        x = ctx["x"].to_i + ctx["width"].to_i - 25
        y = ctx["y"].to_i + 5
        el_type = element_type(element)
        case el_type
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
          $todos[el_type] += 1
          xml.rect(x: ctx["x"], y: ctx["y"], width: ctx["width"], height: ctx["height"])
        end
      end

      def element_text_bounds(element, ctx)
        case element_type(element)
        when "ApplicationService"
          {
            x: ctx["x"].to_i + 10, y: ctx["y"].to_i, width: ctx["width"].to_i - 20, height: ctx["height"]
          }
        when "DataObject"
          {
            x: ctx["x"].to_i + 5, y: ctx["y"].to_i + 14, width: ctx["width"].to_i - 10, height: ctx["height"]
          }
        else
          {
            x: ctx["x"].to_i + 5, y: ctx["y"].to_i, width: ctx["width"].to_i - 30, height: ctx["height"]
          }
        end
      end

      def reset_min_max
        @min_x = 0
        @max_x = 100
        @min_y = 0
        @max_y = 100
      end

      def parse_bounds(bounds_node)
        b = Hash.new { |h, k| h[k] = 0 }
        bounds_node.attributes.select { |k, _v| %w(x y width height).include? k }.each_pair { |k, v| b[k] = v.value.to_i }
        Struct::Bounds.new(b["x"], b["y"], b["width"], b["height"])
      end

      def compute_drawing_bounds(b)
        @min_x = b.x if b.x < @min_x
        @max_x = (b.x + b.width) if (b.x + b.width) > @max_x
        @min_y = b.y if b.y < @min_y
        @max_y = b.y + b.height if b.y + b.height > @max_y
      end

      def draw_element(xml, obj, context = nil)
        bounds = parse_bounds(obj.at_css(">bounds"))
        compute_drawing_bounds(bounds)
        element_id = obj.attr("archimateElement") || obj.attr("id")
        element = obj.document.at_css("##{element_id}")
        group_attrs = { id: element_id, class: element_type(element) }
        group_attrs[:transform] = "translate(#{context['x']}, #{context['y']})" unless context.nil?
        xml.g(group_attrs) do
          draw_element_rect(xml, element, bounds)
          tctx = element_text_bounds(element, bounds)
          y = tctx[:y].to_i
          x = bounds.x + (bounds.width / 2)
          content = element.attr("name") || element.at_css("content").nil? ? "" : element.at_css("content").text
          fit_text_to_width(content, tctx[:width].to_i).each do |line|
            y += 17
            xml.text_(x: x, y: y, "text-anchor" => :middle) do
              xml.text line
            end
          end
          obj.css(">child").each { |child| draw_element(xml, child, bounds) }
        end
      end

      def pos_element(element)
        offset = Struct::Bounds.new(0, 0, 0, 0)
        el = element.parent
        while raw_bounds = el.at_css(">bounds")
          bounds = parse_bounds(raw_bounds)
          offset.x += bounds.x
          offset.y += bounds.y
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

      def draw_connection(xml, obj, _context = nil)
        obj.css("sourceConnection").each do |src_conn|
          source = obj.document.at_css("##{src_conn.attr('source')}")
          source_bounds = parse_bounds(source.at_css(">bounds"))
          target = obj.document.at_css("##{src_conn.attr('target')}")
          target_bounds = parse_bounds(target.at_css(">bounds"))
          src_offset = pos_element(source)
          target_offset = pos_element(target)
          next if source.ancestors.include?(target)
          next if target.ancestors.include?(source)
          rel = src_conn.key?("relationship") ? element_type(obj.document.at_css("##{src_conn.attr('relationship')}")) : ""
          startx = src_offset.x + source_bounds.x + (source_bounds.width / 2)
          starty = src_offset.y + source_bounds.y + (source_bounds.height / 2)
          endx = target_offset.x + target_bounds.x + (target_bounds.width / 2)
          endy = target_offset.y + target_bounds.y + (target_bounds.height / 2)
          xml.path(d: "M #{startx} #{starty} L #{endx} #{endy}", class: rel) do |path|
            path.title do |title|
              source_element = source.key?("archimateElement") ? obj.document.at_css("##{source.attr('archimateElement')}").attr("name") : ""
              target_element = target.key?("archimateElement") ? obj.document.at_css("##{target.attr('archimateElement')}").attr("name") : ""
              title.text "#{rel}: #{source_element} to #{target_element}" unless source_element.empty? || target_element.empty?
            end
          end
        end
      end

      def make_svgs(archi_file)
        doc = Nokogiri::XML(File.open(archi_file))

        doc.css('element[xsi|type="archimate:ArchimateDiagramModel"]').each do |diagram|
          reset_min_max
          svg_doc = Nokogiri::XML::Document.parse(File.read(File.join(File.dirname(__FILE__), "svg_template.svg")))
          svg = svg_doc.at_css("svg")

          name = diagram.attr("name")
          puts name
          diagram.css(">child").each do |child|
            Nokogiri::XML::Builder.with(svg) do |xml|
              draw_element(xml, child)
            end
          end

          diagram.css(">child").each do |child|
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

          File.open("tmp/generated/#{name}.svg", "wb") do |f|
            f.write(svg_doc.to_xml(encoding: 'UTF-8', indent: 2))
          end
        end

        puts "\n\n"
        $todos.keys.sort.each { |el| puts "#{el}: #{$todos[el]}" }
      end
    end
  end
end
