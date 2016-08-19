require "nokogiri"
require "colorize"

module Archimate
  module Cli
    class Merger
      # TODO: handle inner text of elements
      # TODO: handle merging by element type

      def hash_to_attr(h)
        h.map { |k, v| "#{k}=\"#{v}\"" }.join(" ")
      end

      def e_to_s(e)
        "#{e.name} #{hash_to_attr(e.attributes)}"
      end

      # Merge node1, node2
      # For node
      #   For each child
      #     If has a matching child
      def merge(doc1, doc2)
        doc2.children.each do |e|
          next if e.name == "text" && e.text.strip.empty?
          # p = e.path
          # if p =~ /\[\d+\]$/
          #   p = p.gsub(/\[\d+\]$/, "[@name=\"#{e.attr("name")}\"]")
          # end
          # puts "Looking for #{p}"``
          # matches = doc1.xpath(p)
          css = ">#{e.name}"
          # puts css
          css += "[name=\"#{e.attr('name')}\"]" if e.attributes.include?("name")
          css += "[xsi|type=\"#{e.attr('xsi:type')}\"]" if e.attributes.include?("xsi:type")
          matches = doc1.css(css)
          if !matches.empty? # We have a potential match
            # puts "Match?"
            # puts "  Doc2: #{e_to_s(e)}"
            # matches.each do |e1|
            #   puts "  Doc1: #{e_to_s(e1)}"
            # end
            merge(matches[0], e) unless matches.size > 1
          else # No match insert the node into the tree TODO: handle id conflicts
            doc1.add_child(e)
          end
        end
        doc1
      end

      def id_hash_for(doc)
        doc.css("[id]").each_with_object({}) do |obj, memo|
          memo[obj["id"]] = obj
          memo
        end
      end

      def conflicting_ids(doc1, doc2)
        doc_id_hash1 = id_hash_for(doc1)
        doc_id_hash2 = id_hash_for(doc2)
        cids = Set.new(doc_id_hash1.keys) & doc_id_hash2.keys
        # puts "ID Conflicts:"
        # puts cids.to_a.join(",")
        cids
      end

      def merge_files(file1, file2)
        outfile = "tmp/merged.archimate"

        doc1 = Nokogiri::XML(File.open(file1))
        doc2 = Nokogiri::XML(File.open(file2))

        # cids = conflicting_ids(doc1, doc2)
        outdoc = merge(doc1.root, doc2.root).document
        File.open(outfile, "w") do |f|
          f.write(outdoc)
        end
        outdoc
      end
    end
  end
end
