# frozen_string_literal: true
module Archimate
  module Cli
    require "thor"

    class Archi < Thor
      desc "map ARCHIFILE", "EXPERIMENTAL: Produce a map of diagram links to a diagram"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      def map(archifile)
        Archimate::OutputIO.new(options) do |output|
          Archimate::Cli::Mapper.new(Document.read(archifile).doc, output).map
        end
      end

      desc "merge ARCHIFILE1 ARCHIFILE2", "EXPERIMENTAL: Merge two archimate files"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      def merge(archifile1, archifile2)
        Archimate::Cli::Merger.new.merge_files(archifile1, archifile2)
      end

      desc "project ARCHIFILE PROJECTFILE", "EXPERIMENTAL: Synchronize an Archi file and an MSProject XML file"
      def project(archifile, projectfile)
        Archimate::Cli::Projector.new.project(archifile, projectfile)
      end

      desc "svg -o OUTPUTDIR ARCHIFILE", "IN DEVELOPMENT: Produce semantically meaningful SVG files from an Archi file"
      option :output,
             aliases: :o,
             required: true,
             desc: "Write output to OUTPUTDIR"
      def svg(archifile)
        Archimate::Cli::Svger.export_svgs(archifile, Archimate::AIO.new)
      end

      desc "dupes ARCHIFILE", "List all duplicate elements in Archi file"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of STDOUT"
      option :force,
             aliases: :f,
             type: :boolean,
             desc: "Force overwriting of existing output file"
      def dupes(archifile)
        Archimate::OutputIO.new(options) do |output|
          Archimate::Cli::Duper.new(Document.read(archifile), output).list_dupes
        end
      end

      desc "clean ARCHIFILE", "Clean up unreferenced elements and relations"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of replacing ARCHIFILE"
      option :saveremoved,
             aliases: :r,
             desc: "Write removed elements into FILE"
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
             desc: "Merges all duplicates without asking"
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of replacing ARCHIFILE"
      option :force,
             aliases: :f,
             type: :boolean,
             desc: "Force overwriting of existing output file"
      def dedupe(archifile)
        Archimate::OutputIO.new(options, archifile) do |output|
          Archimate::Cli::Duper.new(Document.read(archifile), output, options[:mergeall], options[:force]).merge
        end
      end

      desc "convert ARCHIFILE", "Convert the incoming file to the desired type"
      option :to,
             aliases: :t,
             default: Archimate::Cli::Convert::SUPPORTED_FORMATS.first,
             desc: "File type to convert to. Options are: " \
                   "'meff2.1' for Open Group Model Exchange File Format for ArchiMate 2.1 " \
                   "'archi' for Archi http://archimatetool.com/ file format " \
                   "'nquads' for RDF 1.1 N-Quads format https://www.w3.org/TR/n-quads/",
             enum: Archimate::Cli::Convert::SUPPORTED_FORMATS
      option :output,
             aliases: :o,
             desc: "Write output to FILE instead of stdout."
      option :force,
             aliases: :f,
             type: :boolean,
             desc: "Force overwriting of existing output file"
      def convert(archifile)
        Archimate::OutputIO.new(options) do |output|
          Archimate::Cli::Convert.new.convert(archifile, output, options)
        end
      end
    end
  end
end
