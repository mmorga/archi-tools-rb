# frozen_string_literal: true

require "highline"

module Archimate
  module Cli
    class Duper
      def initialize(model, output, mergeall = false)
        @model = model
        @output = output
        @mergeall = mergeall
        @cli = HighLine.new
        @skipall = false
      end

      def list
        dupes = Archimate::Lint::DuplicateEntities.new(@model)

        dupes.each do |element_type, _name, entities|
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

        dupes.each do |element_type, name, entities|
          handle_duplicate(element_type, name, entities)
        end

        Archimate::FileFormats::ArchiFileWriter.new(@model).write(@output)
      end

      # Belongs to merge
      # 1. Determine which one is the *original*
      protected def handle_duplicate(element_type, name, entities)
        return if @skipall
        first_entity = entities.first
        choice = @mergeall ? first_entity : choices(element_type, name, entities)

        case choice
        when :mergeall
          @mergeall = true
          choice = first_entity
        when :skip
          choice = nil
          @cli.say("Skipping")
        when :skipall
          @skipall = true
          choice = nil
          @cli.say("Skipping")
        end

        return unless choice
        @model.merge_entities(choice, entities)
      end

      # Belongs to handle_duplicate
      protected def choices(element_type, name, entities)
        @cli.choose do |menu|
          # TODO: set up a layout that permits showing a repr of the copies
          # to permit making the choice of the original
          menu.header = "There are #{entities.size} #{element_type}s that are potentially duplicate"
          menu.prompt = "What to do with potential duplicates?"
          entities.each_with_index do |entity, idx|
            menu.choice(entity, help: "Merge entities into this entity")
          end
          # menu.choice(:merge, help: "Merge elements into a single element", text: "Merge elements")
          menu.choice(:mergeall, help: "Merge all elements from here on", text: "Merge all elements")
          # menu.choices(:rename, "Rename to eliminate duplicates", "Rename element(s)")
          menu.choice(:skip, help: "Don't change the elements", text: "Skip")
          menu.choice(:skipall, help: "Skip the rest of the duplicates", text: "Skip the rest")
          menu.select_by = :index_or_name
          menu.help("Help", "don't panic")
        end
      end
    end
  end
end
