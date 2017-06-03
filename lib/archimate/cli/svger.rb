# frozen_string_literal: true

module Archimate
  module Cli
    # This class is used to export SVG diagrams as defined in the given model
    class Svger
      def self.export_svgs(archi_file, output_dir)
        new(Archimate.read(archi_file).diagrams, output_dir).export_svgs
      end

      def initialize(diagrams, output_dir)
        @diagrams = diagrams
        @output_dir = output_dir
      end

      def export_svgs
        progress = ProgressIndicator.new(total: @diagrams.size, title: "Writing SVGs")
        @diagrams.each do |diagram|
          export(diagram)
          progress.increment
        end
      ensure
        progress.finish
      end

      def export(diagram, file_name = nil)
        file_name = Cli.process_svg_filename(file_name || diagram.id)
        File.open(File.join(@output_dir, file_name), "wb") do |svg_file|
          svg_file.write(Svg::Diagram.new(diagram).to_svg)
        end
      end
    end

    def self.process_svg_filename(name)
      file_name = name.strip.tr("/", "-")
      file_name += ".svg" unless file_name =~ /\.svg$/
      file_name
    end
  end
end
