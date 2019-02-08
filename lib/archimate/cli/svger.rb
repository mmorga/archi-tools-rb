# frozen_string_literal: true

module Archimate
  module Cli
    SVG_NAME_OPTION = %i[id name].freeze # TODO: add a way to export in folders with :folder_name]
    DEFAULT_OPTIONS = {
      svg_name: :id,
      format_xml: true,
      legend: false
    }.freeze

    # This class is used to export SVG diagrams as defined in the given model
    class Svger
      attr_reader :options

      def self.export_svgs(archi_file, output_dir, options = {})
        new(Archimate.read(archi_file).diagrams, output_dir, options).export_svgs
      end

      def initialize(diagrams, output_dir, options = {})
        @options = DEFAULT_OPTIONS.merge(options)
        @diagrams = diagrams
        @output_dir = output_dir
        @diagram_base_names = {}
      end

      def export_svgs
        @diagram_base_names = {}
        progress = ProgressIndicator.new(total: @diagrams.size, title: "Writing SVGs")
        @diagrams.each do |diagram|
          export(diagram, filename_for(diagram, options[:svg_name]))
          progress.increment
        end
      ensure
        progress.finish
      end

      def export(diagram, file_name = nil)
        file_name = Cli.process_svg_filename(file_name || diagram.id)
        File.open(File.join(@output_dir, file_name), "wb") do |svg_file|
          svg_file.write(Svg::Diagram.new(diagram, options).to_svg)
        end
      end

      # TODO: in case of duplicate name in a model, we need to extend the filename with a numeric or something.
      def filename_for(diagram, name_option)
        base_name = diagram_base_name(diagram, name_option)
        if @diagram_base_names.include?(base_name)
          idx = 2
          idx += 1 while @diagram_base_names.include?(base_name + " - #{idx}")
          base_name += " - #{idx}"
        end
        base_name
      end

      def diagram_base_name(diagram, name_option)
        case name_option
        when :name
          diagram.name
        # when :folder_name
        #   diagram.name # TODO: add the path
        else
          diagram.id
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
