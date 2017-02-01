# frozen_string_literal: true
module Archimate
  module Cli
    require "thor"

    class Archi < Thor
      desc "stats ARCHIFILE", "Show some statistics about the model"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def stats(archifile)
        Archimate::Cli::Stats.new(
          Archimate::AIO.new(
            input_io: archifile,
            interactive: !options.fetch("noninteractive", false)
          )
        ).statistics
      end

      desc "map ARCHIFILE", "Produce a map of diagram links to a diagram"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def map(archifile)
        Archimate::Cli::Mapper.new(
          Archimate::AIO.new(
            input_io: archifile,
            output_io: options.fetch("output", $stdout),
            interactive: !options.fetch("noninteractive", false)
          )
        ).map
      end

      desc "merge ARCHIFILE1 ARCHIFILE2", "EXPERIMENTAL: Merge two archimate files"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      def merge(archifile1, archifile2)
        Archimate::Cli::Merger.new.merge_files(archifile1, archifile2)
      end

      desc "svg -o OUTPUTDIR ARCHIFILE", "IN DEVELOPMENT: Produce semantically meaningful SVG files from an Archi file"
      option :output,
             aliases: :o,
             required: true,
             desc: "Write output to OUTPUTDIR"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def svg(archifile)
        Archimate::Cli::Svger.export_svgs(
          archifile,
          Archimate::AIO.new(
            output_dir: options.fetch("output", Dir.pwd),
            interactive: !options.fetch("noninteractive", false)
          )
        )
      end

      desc "clean ARCHIFILE", "Clean up unreferenced elements and relations"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of replacing ARCHIFILE"
      option :saveremoved,
             aliases: :r,
             desc: "Write removed elements into FILE"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def clean(archifile)
        outfile = options.key?(:output) ? options[:output] : archifile
        Archimate::MaybeIO.new(options.fetch(:saveremoved, nil)) do |removed_element_io|
          Archimate::Cli::Cleanup.new(archifile, outfile, removed_element_io)
        end
      end

      desc "dedupe ARCHIFILE", "de-duplicate elements in Archi file"
      option :mergeall,
             aliases: :m,
             type: :boolean,
             default: false,
             desc: "Merges all duplicates without asking"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of replacing ARCHIFILE"
      option :force,
             aliases: :f,
             type: :boolean,
             default: false,
             desc: "Force overwriting of existing output file"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def dedupe(archifile)
        Archimate::Cli::Duper.new(
          AIO.new(
            input_io: archifile,
            output_io: options.fetch("output", archifile),
            force: options[:force],
            interactive: !options[:noninteractive]
          ),
          options[:mergeall]
        ).merge
      end

      desc "convert ARCHIFILE", "Convert the incoming file to the desired type"
      option :to,
             aliases: :t,
             default: Archimate::Cli::Convert::SUPPORTED_FORMATS.first,
             desc: "File type to convert to. Options are: " \
                   "'meff2.1' for Open Group Model Exchange File Format for ArchiMate 2.1 " \
                   "'archi' for Archi http://archimatetool.com/ file format " \
                   "'nquads' for RDF 1.1 N-Quads format https://www.w3.org/TR/n-quads/" \
                   "'graphml' for GraphML" \
                   "'csv' for CSV files (one file per element/relationship type",
             enum: Archimate::Cli::Convert::SUPPORTED_FORMATS
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      option :outputdir,
             aliases: :d,
             desc: "Write output to DIRECTORY."
      option :force,
             aliases: :f,
             type: :boolean,
             desc: "Force overwriting of existing output file"
      option :noninteractive,
             aliases: :n,
             type: :boolean,
             default: false,
             desc: "Don't provide interactive feedback"
      def convert(archifile)
        Archimate::Cli::Convert.new(
          Archimate::AIO.new(
            input_io: archifile,
            output_dir: options.fetch("outputdir", Dir.pwd),
            force: options.fetch("force", false),
            output_io: options.fetch("output", $stdout),
            interactive: !options.fetch("noninteractive", false)
          )
        ).convert(options[:to])
      end

      desc "lint ARCHIFILE", "Examine the ArchiMate file for potential problems"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of STDOUT"
      def lint(archifile)
        Archimate::Cli::Lint.new(
          Archimate::AIO.new(
            input_io: archifile,
            output_io: options.fetch("output", $stdout)
          )
        ).lint
      end
    end
  end
end
