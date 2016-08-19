module Archimate
  module Cli
    class XmlTextconv
      DIAGRAM_ELEMENT_ORDER = %w(bendpoint bounds sourceConnection child content
                                 documentation property folder element).freeze
      FOLDER_TYPE_ORDER = %w(business application technology motivation
                             implementation_migration connectors relations
                             derived diagrams).freeze

      def initialize(input_file, _output_file = nil)
        doc = Nokogiri::XML(File.read(input_file))

        output = StringIO.new

        output.puts('<?xml version="1.0" encoding="UTF-8"?>')
        fmt_node(output, [], doc.root)

        puts output.string
      end

      def indent(depth)
        " " * (depth * 2)
      end

      def comp_elements(a, b)
        if a.name == b.name && a.name == "element"
          a.attr("id") <=> b.attr("id")
        # TODO: property
        elsif a.name == b.name && a.name == "folder"
          if a.key?("type") && b.key?("type")
            FOLDER_TYPE_ORDER.index(a.attr("type")) <=> FOLDER_TYPE_ORDER.index(b.attr("type"))
          else
            a.attr("name") <=> b.attr("name")
          end
        elsif !DIAGRAM_ELEMENT_ORDER.include?(a.name)
          puts "missing a.name #{a.name} compared with #{b.name}"
        elsif !DIAGRAM_ELEMENT_ORDER.include?(b.name)
          puts "missing b.name #{b.name} compared with #{a.name}"
        else
          DIAGRAM_ELEMENT_ORDER.index(a.name) <=> DIAGRAM_ELEMENT_ORDER.index(b.name)
        end
      end

      def pre_process(nodes)
        filtered = nodes.each_with_object([]) do |i, a|
          a << i unless i.is_a?(Nokogiri::XML::Text) && i.text.strip.empty?
        end
        filtered.sort do |a, b|
          if a.is_a?(Nokogiri::XML::Element) && b.is_a?(Nokogiri::XML::Element)
            comp_elements(a, b)
          elsif a.attr("id").nil?
            puts "COMPARE: #{a.class.name} #{a.name} #{a.attributes.keys.sort.join(',')} " \
                 "w/ #{b.class.name} #{b.name} #{b.attributes.keys.sort.join(',')}"
            1
          elsif b.attr("id").nil?
            puts "COMPARE: #{a.class.name} #{a.name} #{a.attributes.keys.sort.join(',')} " \
                 "w/ #{b.class.name} #{b.name} #{b.attributes.keys.sort.join(',')}"
            -1
          else
            a.attr("id") <=> b.attr("id")
          end
        end
      end

      def fmt_node(output, path, node)
        case node.class.name
        when "Nokogiri::XML::Element"
          attrs = node.attributes
          id = attrs.delete("id")
          attrs = attrs.each_with_object({}) { |i, a| a[i.first] = i.last }
          # attrs.merge!(node.namespaces)
          output.write indent(path.size)
          element_name = node.namespace.nil? ? node.name : "#{node.namespace.prefix}:#{node.name}"
          output.write "<#{element_name}"
          output.write " id=\"#{id}\"" unless id.nil?
          output.write "\n"
          attrs.keys.sort.each do |attr_key|
            output.write indent(path.size + 1)
            output.write "#{attr_key}=\"#{attrs[attr_key]}\"\n"
          end
          children = pre_process(node.children)
          if children.empty?
            output.write indent(path.size + 1)
            output.write "/>\n"
          else
            output.write indent(path.size + 1)
            output.write ">\n"
            path.push(node.name)
            children.each do |child|
              fmt_node(output, path, child)
            end
            path.pop
            output.write indent(path.size)
            output.write "</#{element_name}>\n"
          end
        when "Nokogiri::XML::Text"
          text = node.text.strip
          output.puts(text) unless text.empty?
        else
          output.puts "node.class = #{node.class.name}"
        end
      end
    end
  end
end
