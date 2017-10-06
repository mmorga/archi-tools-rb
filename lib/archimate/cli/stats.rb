# frozen_string_literal: true

module Archimate
  module Cli
    class Stats
      attr_reader :output_io
      attr_reader :model

      def initialize(model, output_io)
        @model = model
        @output_io = output_io
      end

      def statistics
        output_io.puts Color.color("#{model.name} ArchiMate Model Statistics\n", :headline)

        output_io.puts "Elements:"
        elements_by_layer.each do |layer, elements|
          output_io.puts row(layer, elements.size, layer)
        end
        output_io.puts row("Total Elements", model.elements.size, :horizontal_line)
        output_io.puts row("Relationships", model.relationships.size, :Relationship)
        output_io.puts row("Diagrams", model.diagrams.size, :Diagram)
      end

      def elements_by_layer
        @elements_by_layer ||= model.elements.group_by(&:layer)
      end

      def title_width
        @title_width ||= (elements_by_layer.keys + ["Total Elements"]).map(&:size).max
      end

      def row(title, size, color)
        @title_format_str ||= "%#{title_width}s"
        @count_format_str ||= "%7d"

        Color.color(format(@title_format_str, title), color) + format(@count_format_str, size)
      end
    end
  end
end
