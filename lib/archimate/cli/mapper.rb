# frozen_string_literal: true

module Archimate
  module Cli
    class Mapper
      HEADERS = %w[id name viewpoint].freeze
      COL_DIVIDER = " | "

      attr_reader :model

      def initialize(model, output_io)
        @model = model
        @output = output_io
      end

      def header_row(widths, headers)
        titles = []
        widths.each_with_index { |w, i| titles << format("%-#{w}s", headers[i]) }
        @output.puts titles.map { |t| Color.color(t.capitalize, %i[bold blue]) }.join(Color.color(COL_DIVIDER, :light_black))
        @output.puts Color.color(widths.map { |w| "-" * w }.join("-+-"), :light_black)
      end

      def process_diagrams(diagrams)
        diagrams.map { |e| [e.id, e.name, e.viewpoint, e.type] }.map do |row|
          row[2] = case row[3]
                   when "canvas:CanvasModel"
                     ["Canvas", row[4]].compact.join(": ")
                   when "archimate:SketchModel"
                     "Sketch"
                   when "archimate:ArchimateDiagramModel"
                     DataModel::Constants::VIEWPOINTS[(row[2] || 0).to_i]
                   else
                     row[3]
                   end
          row[0] = Color.color("#{row[0]}.png", :underline)
          row
        end
      end

      def compute_column_widths(diagrams, headers)
        initial_widths = headers.map(&:size)
        diagrams.each_with_object(initial_widths) do |diagram, memo|
          diagram.slice(0, headers.size).each_with_index do |o, i|
            memo[i] = !o.nil? && Color.uncolor(o).size > memo[i] ? Color.uncolor(o).size : memo[i]
          end
          memo
        end
      end

      def output_diagrams(diagrams, widths)
        diagrams.sort_by { |a| a[1] }.each do |m|
          row = []
          m.slice(0, widths.size).each_with_index { |c, i| row << format("%-#{widths[i]}s", c) }
          @output.puts row.join(Color.color(COL_DIVIDER, :light_black))
        end
      end

      def build_organization_hash(organizations, parent = "", hash = {})
        organizations.each_with_object(hash) do |i, a|
          organization_path = [parent, i.name].join("/")
          a[organization_path] = i
          build_organization_hash(i.organizations, organization_path, a)
        end
      end

      def map
        widths = compute_column_widths(process_diagrams(model.diagrams), HEADERS)
        adjusted_widths = widths.inject(COL_DIVIDER.size * (HEADERS.size - 1), &:+)
        header_row(widths, HEADERS)
        organization_paths = build_organization_hash(model.organizations)
        organization_paths.keys.sort.each do |organization_name|
          diagrams = organization_paths[organization_name].items.map { |i| model.lookup(i) }.select { |i| i.is_a?(DataModel::Diagram) }
          next if diagrams.empty?
          @output.puts(Color.color(format("%-#{adjusted_widths}s", organization_name), %i[bold green on_light_black]))
          output_diagrams(process_diagrams(diagrams), widths)
        end

        @output.puts "\n#{model.diagrams.size} Diagrams"
      end
    end
  end
end
