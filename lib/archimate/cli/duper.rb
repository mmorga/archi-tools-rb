# frozen_string_literal: true

require "highline"

module Archimate
  module Cli
    class Duper
      def initialize(aio, mergeall = false)
        @output = aio.output_io
        @cli = HighLine.new
        @model = aio.model
        @skipall = false
        @mergeall = mergeall
      end

      def dupe_list
        dupes = Hash.new { |type_hash, el_type_name| type_hash[el_type_name] = Hash.new { |name_hash, name| name_hash[name] = [] } }
        @model.element_type_names.each do |el_type|
          @model.elements_with_type(el_type).each do |el|
            dupes[el_type.to_s][simplify(el.label)] << el.id
          end
        end
        dupes.delete_if do |_key, val|
          val.delete_if { |_k2, v2| v2.size <= 1 }
          val.size.zero?
        end
        dupes
      end

      # This method takes an entity name (label) and simplifies it for duplicate determination
      # This might be configurable in the future
      # 1. names are explicitly identical
      # 2. names differ only in case
      # 3. names differ only in whitespace
      # 4. names differ only in punctuation
      # 5. names differ only by stop-words (TBD list of words such as "the", "api", etc.)
      def simplify(name)
        return name unless name
        name.downcase.delete(" \t\n\r").gsub(/[[:punct:]]/, "")
      end

      def list_dupes
        dupes = dupe_list

        count = dupes.reduce(0) do |memo, obj|
          memo + obj[1].reduce(0) { |a, e| a + e[1].size }
        end

        dupes.keys.each do |element_type|
          dupes[element_type].keys.each do |name|
            @output.puts "The name '#{name}' is used more than once for the type '#{element_type}'. "\
              "Identifiers: #{dupes[element_type][name].inspect}"
          end
        end
        @output.puts "Total Possible Duplicates: #{count}"
      end

      def merge_duplicates(original_id, dupe_ids)
        copies_ids = dupe_ids.reject { |id| id == original_id }
        merge_copies(original_id, copies_ids)
        remove_copies(copies_ids)
        update_associations(original_id, copies_ids)
      end

      def display_elements(ids)
        ids.each_with_index do |id, idx|
          puts "#{idx}. #{@model.stringize(@model.element_by_identifier(id))}\n"
        end
      end

      def choices(element_type, name, ids)
        if @mergeall
          :mergeall
        elsif @skipall
          :skipall
        else
          @cli.choose do |menu|
            # TODO: set up a layout that permits showing a repr of the copies
            # to permit making the choice of the original
            menu.header = "There are #{ids.size} #{element_type}s with the name #{name}"
            menu.prompt = "What to do with potential duplicates?"
            menu.choice(:merge, help: "Merge elements into a single element", text: "Merge elements")
            menu.choice(:mergeall, help: "Merge all elements from here on", text: "Merge all elements")
            # menu.choices(:rename, "Rename to eliminate duplicates", "Rename element(s)")
            menu.choice(:skip, help: "Don't change the elements", text: "Skip")
            menu.choice(:skipall, help: "Skip the rest of the duplicates", text: "Skip the rest")
            menu.select_by = :index_or_name
            menu.help("Help", "don't panic")
          end
        end
      end

      # 1. Determine which one is the *original*
      def handle_duplicate(element_type, name, ids)
        display_elements(ids)
        choice = choices(element_type, name, ids)
        @mergeall = true if choice == :mergeall

        case choice
        when :merge, :mergeall
          original_id = ids.first # TODO: let the user choose this
          merge_duplicates(original_id, ids)
        when :skip, :skipall
          @cli.say("Skipping")
        end
      end

      def merge_into(original, copy)
        copy.elements.each do |child|
          # TODO: is there a better test than this?
          if original.children.none? { |original_child| child.to_xml == original_child.to_xml }
            child.parent = original
          end
        end
      end

      # 2. Copy any attributes/docs, etc. from each of the others into the original.
      #     1. Child `label`s with different `xml:lang` attribute values
      #     2. Child `documentation` (and different `xml:lang` attribute values)
      #     3. Child `properties`
      #     4. Any other elements
      def merge_copies(original_id, copies_ids)
        original = @model.element_by_identifier(original_id)
        copies_ids.each do |copy_id|
          copy = @model.element_by_identifier(copy_id)
          merge_into(original, copy)
        end
      end

      # 3. Delete the copy element from the document
      def remove_copies(copies_ids)
        copies_ids.each do |copy_id|
          @model.element_by_identifier(copy_id).remove
        end
      end

      # 4. For each copy, change references from copy id to original id
      #     1. `relationship`: `source` & `target` attributes
      #     2. `property`: `identifierref` attribute
      #     3. `item`: `identifierref` attribute
      #     4. `node`: `elementref` attribute
      #     5. `connection`: `relationshipref`, `source`, `target` attributes
      def update_associations(original_id, copies_ids)
        copies_ids.each do |copy_id|
          @model.elements_with_attribute_value(copy_id).each do |node|
            attrs = node.attributes
            attrs.delete("identifier") # We shouldn't get a match here, but would be a bug
            attrs.each do |_attr_name, attr|
              attr.value = original_id if attr.value == copy_id
            end
          end
        end
      end

      def merge
        dupes = dupe_list
        if dupes.empty?
          @output.puts "No potential duplicates detected"
          return
        end

        # TODO: sort keys by layer, then alphabetical, then connections
        dupes.keys.each do |element_type|
          dupes[element_type].keys.sort.each do |name|
            handle_duplicate(element_type, name, dupes[element_type][name])
          end
        end

        @output.write(@model.doc)
      end
    end
  end
end
