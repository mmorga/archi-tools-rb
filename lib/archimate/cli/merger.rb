# frozen_string_literal: true

module Archimate
  module Cli
    # Merger is a class that is a decorator on Archimate::DataModel::Model
    # to provide the capability to merge another model into itself
    #
    # TODO: provide for a conflict resolver instance
    # TODO: provide an option to determine if potential matches are merged
    #       or if the conflict resolver should be asked.
    class Merger # < SimpleDelegator
      # def initialize(primary_model, conflict_resolver)
      #   super(primary_model)
      #   @resolver = conflict_resolver
      # end

      # What merge does:
      # For all entities: (other than Model...):
      #   - PropertyDefinition
      #   - View
      #   - Viewpoint
      # Entity:
      #   look for a matching entity: with result
      #     1. Found a matching entity: goto entity merge
      #     2. Found no matching entity, but id conflicts: gen new id, goto add entity
      #     3. Found no matching entity: goto add entity
      #   entity merge:
      #     1. merge (with func from deduper)
      #   add entity:
      #     1. add entity to model
      #   add remapping entry to map from entities other model id to id in this model
      # Relationship:
      # def merge(other_model)
      #   other_model.entities.each do |entity|
      #     # TODO: matching entity should use the same criteria that DuplicateEntities uses.
      #     my_entity = find_matching_entity(entity)
      #     if my_entity
      #   end
      # end

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
        doc1 = Nokogiri::XML(File.open(file1))
        doc2 = Nokogiri::XML(File.open(file2))

        # cids = conflicting_ids(doc1, doc2)
        merge(doc1.root, doc2.root).document
      end
    end
  end
end
