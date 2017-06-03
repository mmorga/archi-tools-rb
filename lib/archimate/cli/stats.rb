# frozen_string_literal: true
require 'forwardable'

module Archimate
  module Cli
    class Stats
      extend Forwardable

      def_delegator :@aio, :model
      def_delegator :@aio, :puts

      def initialize(aio)
        @aio = aio
      end

      def statistics
        puts Color.color("#{model.name} ArchiMate Model Statistics\n", :headline)

        puts "Elements:"
        elements_by_layer.each do |layer, elements|
          puts row(layer, elements.size, layer)
        end
        puts row("Total Elements", model.elements.size, :horizontal_line)
        puts row("Relationships", model.relationships.size, :Relationship)
        puts row("Diagrams", model.diagrams.size, :Diagram)
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
