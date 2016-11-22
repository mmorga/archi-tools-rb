# frozen_string_literal: true
module Archimate
  module Cli
    class Mapper
      VIEWPOINTS = ["Total", "Actor Co-operation", "Application Behaviour",
                    "Application Co-operation", "Application Structure", "Application Usage",
                    "Business Function", "Business Process Co-operation", "Business Process",
                    "Business Product", "Implementation and Deployment", "Information Structure",
                    "Infrastructure Usage", "Infrastructure", "Layered", "Organisation",
                    "Service Realisation", "Stakeholder", "Goal Realization", "Goal Contribution",
                    "Principles", "Requirements Realisation", "Motivation", "Project",
                    "Migration", "Implementation and Migration"].freeze

      HEADERS = %w(id name viewpoint).freeze
      COL_DIVIDER = " | "

      attr_reader :model

      def initialize(model, output_io)
        @model = model
        @output = output_io
      end

      def header_row(widths, headers)
        titles = []
        widths.each_with_index { |w, i| titles << "%-#{w}s" % headers[i] }
        @output.puts titles.map { |t| t.capitalize.bold.blue }.join(COL_DIVIDER.light_black)
        @output.puts widths.map { |w| "-" * w }.join("-+-").light_black
      end

      def process_diagrams(diagrams)
        diagrams.map { |e| [e.id, e.name, e.viewpoint, e.type] }.map do |row|
          row[2] = case row[3]
                   when "canvas:CanvasModel"
                     ["Canvas", row[4]].compact.join(": ")
                   when "archimate:SketchModel"
                     "Sketch"
                   when "archimate:ArchimateDiagramModel"
                     VIEWPOINTS[(row[2] || 0).to_i]
                   else
                     row[3]
                   end
          row[0] = "#{row[0]}.png".underline
          row
        end
      end

      def compute_column_widths(diagrams, headers)
        initial_widths = headers.map(&:size)
        diagrams.each_with_object(initial_widths) do |diagram, memo|
          diagram.slice(0, headers.size).each_with_index do |o, i|
            memo[i] = !o.nil? && HighLine.uncolor(o).size > memo[i] ? HighLine.uncolor(o).size : memo[i]
          end
          memo
        end
      end

      def output_diagrams(diagrams, widths)
        diagrams.sort { |a, b| a[1] <=> b[1] }.each do |m|
          row = []
          m.slice(0, widths.size).each_with_index { |c, i| row << "%-#{widths[i]}s" % c }
          @output.puts row.join(COL_DIVIDER.light_black)
        end
      end

      def build_folder_hash(folders, parent = "", hash = {})
        folders.each_with_object(hash) do |i, a|
          folder_path = [parent, i.name].join("/")
          a[folder_path] = i
          build_folder_hash(i.folders, folder_path, a)
        end
      end

      def map
        widths = compute_column_widths(process_diagrams(model.diagrams), HEADERS)
        adjusted_widths = widths.inject(COL_DIVIDER.size * (HEADERS.size - 1), &:+)
        header_row(widths, HEADERS)
        folder_paths = build_folder_hash(model.folders)
        folder_paths.keys.sort.each do |folder_name|
          diagrams = folder_paths[folder_name].items.map { |i| model.lookup(i) }.select { |i| i.is_a?(DataModel::Diagram) }
          next if diagrams.empty?
          @output.puts(format("%-#{adjusted_widths}s", folder_name).bold.green.on_light_black)
          output_diagrams(process_diagrams(diagrams), widths)
        end

        @output.puts "\n#{model.diagrams.size} Diagrams"
      end
    end
  end
end
