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
        model = Archimate.read(infile)
        return if model.nil?

        case options["to"]
        when "archi"
          Archimate::FileFormats::ArchiFileWriter.new(model).write(output)
        when "meff2.1"
          Archimate::FileFormats::ModelExchangeFileWriter.new(model).write(output)
        when "nquads"
          output.write(Archimate::Export::NQuads.new(model).to_nq)
        when "graphml"
          output.write(Archimate::Export::GraphML.new(model).to_graphml)
        else
          @io.error "Export to '#{options['to']}' is not supported yet."
        end
      end
    end
  end
end
