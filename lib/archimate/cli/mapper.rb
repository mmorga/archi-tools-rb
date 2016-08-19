require "nokogiri"
require "colorize"

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
      DIAGRAM_SELECTOR = '[xsi|type="archimate:ArchimateDiagramModel"],[xsi|type="archimate:SketchModel"],[xsi|type="canvas:CanvasModel"]'.freeze
      COL_DIVIDER = " | ".freeze

      def initialize(doc, output_io)
        @doc = doc
        @output = output_io
      end

      def header_row(widths, headers)
        titles = []
        widths.each_with_index { |w, i| titles << "%-#{w}s" % headers[i] }
        @output.puts titles.map { |t| t.capitalize.colorize(mode: :bold, color: :blue) }.join(COL_DIVIDER.light_black)
        @output.puts widths.map { |w| "-" * w }.join("-+-").light_black
      end

      def process_diagrams(raw_diagrams)
        raw_diagrams.map do |e|
          [e.attr("id"), e.attr("name"), e.attr("viewpoint"),
           e.attribute_with_ns("type", "http://www.w3.org/2001/XMLSchema-instance").value, e.attr("hintTitle")]
        end.map do |row|
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
          row[0] = "http://10.14.212.38/rax-architecture/images/#{row[0]}.png".underline
          row
        end
      end

      def compute_column_widths(diagrams, headers)
        initial_widths = headers.map(&:size)
        diagrams.each_with_object(initial_widths) do |diagram, memo|
          diagram.slice(0, headers.size).each_with_index do |o, i|
            memo[i] = !o.nil? && o.uncolorize.size > memo[i] ? o.uncolorize.size : memo[i]
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

      def full_folder_name(folder)
        (folder.ancestors.map { |e| e.attr("name") }.compact.reverse << folder.attr("name")).join("/")
      end

      def map
        # <element xsi:type="archimate:ArchimateDiagramModel" id="d615e713" name="Rapid Provisioning Integration" viewpoint="3">

        diagrams = process_diagrams(@doc.css(DIAGRAM_SELECTOR))

        widths = compute_column_widths(diagrams, HEADERS)

        header_row(widths, HEADERS)

        # Display folders by path in alphabetical order
        folder_paths = (@doc.css('folder[name="Views"] folder') + @doc.css('folder[name="Views"]')).each_with_object({}) do |folder, memo|
          memo[full_folder_name(folder)] = folder
          memo
        end

        folder_paths.keys.sort.each do |folder_name|
          @output.puts ("%-#{widths.inject(COL_DIVIDER.size * (HEADERS.size - 1), &:+)}s" % folder_name).colorize(mode: :bold, color: :green, background: :light_black)
          output_diagrams(process_diagrams(folder_paths[folder_name].css(">" + DIAGRAM_SELECTOR)), widths)
        end

        @output.puts "\n#{diagrams.size} Diagrams"
      end
    end
  end
end
