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

      def list
        dupes = Archimate::Lint::DuplicateEntities.new(@model)

        dupes.each do |element_type, name, entities|
          @output.puts "#{element_type} has potential duplicates: \n\t#{entities.join(",\n\t")}\n"
        end
        @output.puts "Total Possible Duplicates: #{dupes.count}"
      end

      def merge
        dupes = Archimate::Lint::DuplicateEntities.new(@model)
        if dupes.empty?
          @output.puts "No potential duplicates detected"
          return
        end

        dupes.each do |element_type, name, ids|
          handle_duplicate(element_type, name, ids)
        end

        @output.write(@model.doc)
      end

      # Belongs to handle_duplicate
      protected def merge_duplicates(original_id, dupe_ids)
        copies_ids = dupe_ids.reject { |id| id == original_id }
        merge_copies(original_id, copies_ids)
        remove_copies(copies_ids)
        update_associations(original_id, copies_ids)
      end

      # Belongs to handle_duplicate
      protected def display_elements(ids)
        ids.each_with_index do |id, idx|
          puts "#{idx}. #{@model.lookup(id).to_s}\n"
        end
      end

      # Belongs to handle_duplicate
      protected def choices(element_type, name, ids)
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

      # Belongs to merge
      # 1. Determine which one is the *original*
      protected def handle_duplicate(element_type, name, ids)
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

      # Belongs to merge_copies
      protected def merge_into(original, copy)
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
      # Belongs to merge_duplicates
      protected def merge_copies(original_id, copies_ids)
        original = @model.lookup(original_id)
        copies_ids.each do |copy_id|
          copy = @model.lookup(copy_id)
          merge_into(original, copy)
        end
      end

      # 3. Delete the copy element from the document
      # Belongs to merge_duplicates
      protected def remove_copies(copies_ids)
        copies_ids.each do |copy_id|
          @model.lookup(copy_id).remove
        end
      end

      # 4. For each copy, change references from copy id to original id
      #     1. `relationship`: `source` & `target` attributes
      #     2. `property`: `identifierref` attribute
      #     3. `item`: `identifierref` attribute
      #     4. `node`: `elementref` attribute
      #     5. `connection`: `relationshipref`, `source`, `target` attributes
      # Belongs to merge_duplicates
      protected def update_associations(original_id, copies_ids)
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
    end
  end
end
