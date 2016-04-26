require "nokogiri"

module Archimate
  class Duper
    XSI = "http://www.w3.org/2001/XMLSchema-instance".freeze

    def element_type(el)
      el.attribute_with_ns("type", XSI).value[10..-1]
    end

    def list_dupes(archi_file)
      elhash = Hash.new { |hash, key| hash[key] = [] }
      doc = Nokogiri::XML(File.open(archi_file))
      doc.css('elements').each do |node|
        next unless node.key?("type") && node.key?("name")
        key = "type=\"#{node.attr('xsi:type')}\" name=\"#{node.attr('name')}\""
        elhash[key] << node.attr("id")
      end

      dupes = elhash.select { |_k, v| v.size > 1 }
      dupes.each { |k, v| puts "#{k} dupes with ids: #{v.join(', ')}" }
    end

    def merge(archi_file, primary_id, secondary_id)
      doc = Nokogiri::XML(File.open(archi_file))
      primary_node = doc.at_css("##{primary_id}")
      return false unless primary_node
      secondary_node = doc.at_css("##{secondary_id}")
      return false unless secondary_node
      attrs = secondary_node.attributes.reject { |k, _v| %w(type id name).include?(k) }
      attrs.each do |k, v|
        primary_node.attr(k, "#{v}#{primary_node.attr(k)}")
      end
      secondary_node.children.each { |node| primary_node.children << node }

      # delete node with id = secondary_id
      secondary_node.parent.children.delete(secondary_node)

      # for each node with target, source, or archimateElement = secondary_id, replace with primary_id
      %w(source target archimateElement).each do |attr_name|
        doc.css("[#{attr_name}=#{secondary_id}]").attr(attr_name, primary_id)
      end

      outfile = "deduped.archimate"
      File.open(outfile, "w") do |f|
        f.write(doc)
      end
    end
  end
end
