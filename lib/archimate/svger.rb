require "nokogiri"
require 'RMagick'

module Archimate
  class Svger
    XSI = "http://www.w3.org/2001/XMLSchema-instance".freeze

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

    def draw_element(xml, obj, context = nil)
      bounds = obj.at_css(">bounds")
      element_id = obj.attr("archimateElement") || obj.attr("id")
      element = obj.document.at_css("##{element_id}")
      group_attrs = { id: element_id, class: element_type(element) }
      group_attrs[:transform] = "translate(#{context['x']}, #{context['y']})" unless context.nil?
      xml.g(group_attrs) do
        draw_element_rect(xml, element, bounds)
        tctx = element_text_bounds(element, bounds)
        y = tctx[:y].to_i
        x = bounds[:x].to_i + (bounds[:width].to_i / 2)
        content = element.attr("name") || element.at_css("content").text
        fit_text_to_width(content, tctx[:width].to_i).each do |line|
          y += 17
          xml.text_(x: x, y: y, "text-anchor" => :middle) do
            xml.text line
          end
        end
        obj.css(">child").each { |child| draw_element(xml, child, bounds) }
      end
      # <sourceConnection xsi:type="archimate:Connection" id="fcaf65b3"
      # source="d3f3af37" target="f38c4ad9" relationship="e5ceb2c2"/>
      obj.css(">sourceConnection").each do |src_conn|
        puts src_conn
        target = obj.document.at_css("##{src_conn.attr('target')}")
        rel = src_conn.key?("relationship") ? element_type(obj.document.at_css("##{src_conn.attr('relationship')}")) : ""
        startx = bounds[:x].to_i + (bounds[:width].to_i / 2)
        starty = bounds[:y].to_i + (bounds[:height].to_i / 2)
        target_bounds = target.at_css(">bounds")
        endx = target_bounds[:x].to_i + (target_bounds[:width].to_i / 2)
        endy = target_bounds[:y].to_i + (target_bounds[:height].to_i / 2)
        xml.path(d: "M #{startx} #{starty} L #{endx} #{endy}", class: rel)
      end
    end

    def make_svgs(archi_file)
      doc = Nokogiri::XML(File.open(archi_file))

      doc.css('element[xsi|type="archimate:ArchimateDiagramModel"]').each do |diagram|
        svg_doc = Nokogiri::XML::Document.parse(File.read(File.join(File.dirname(__FILE__), "svg_template.svg")))
        svg = svg_doc.at_css("svg")
        name = diagram.attr("name")
        puts name
        diagram.css(">child").each do |child|
          Nokogiri::XML::Builder.with(svg) do |xml|
            draw_element(xml, child)
          end
        end

        File.open("generated/#{name}.svg", "wb") do |f|
          f.write(svg_doc.to_xml)
        end
      end

      puts "\n\n"
      $todos.keys.sort.each { |el| puts "#{el}: #{$todos[el]}" }
    end
  end
end
