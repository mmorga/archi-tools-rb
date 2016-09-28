# frozen_string_literal: true
module Archimate
  module Cli
    class Convert
      SUPPORTED_FORMATS = %w(meff2.1 archi nquads graphml).freeze

      def initialize(io = AIO.new)
        @io = io
      end

      def convert(infile, output, options)
        return unless output

        case options["to"]
        when "meff2.1"
          File.open(infile) do |f|
            parser = Archimate::Conversion::ArchiToMeff.new(output)
            Ox.sax_parse(parser, f)
            @io.debug "Done parsing: elements with id count: #{parser.id_map.keys.size}"
            # output.write Ox.dump(parser.doc)
            parser.doc.close
          end
          # output.write(Archimate::Conversion.meff_from_archi(doc.doc).to_xml)
        when "nquads"
          doc = Document.read(infile)
          return if doc.nil?
          output.write(Archimate::Conversion::Quads.new.n_quads(doc))
        when "graphml"
          model = Archimate::ArchiFileReader.read(infile)
          return if model.nil?
          output.write(Archimate::Conversion::GraphML.new.graph_ml(model))
        else
          @io.error "Conversion to '#{to_format}' is not supported yet."
        end
      end
    end
  end
end
