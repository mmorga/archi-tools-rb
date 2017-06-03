# frozen_string_literal: true

module Archimate
  module Cli
    class Convert
      SUPPORTED_FORMATS = %w[meff2.1 archi nquads graphml csv cypher].freeze

      def initialize(io = AIO.new)
        @io = io
      end

      def convert(export_format)
        model = @io.model
        output = @io.output_io
        output_dir = @io.output_dir
        return unless output
        return unless model

        case export_format
        when "archi"
          Archimate::FileFormats::ArchiFileWriter.new(model).write(output)
        when "meff2.1"
          Archimate::FileFormats::ModelExchangeFileWriter.new(model).write(output)
        when "nquads"
          output.write(Archimate::Export::NQuads.new(model).to_nq)
        when "graphml"
          output.write(Archimate::Export::GraphML.new(model).to_graphml)
        when "csv"
          Archimate::Export::CSVExport.new(model).to_csv(output_dir: output_dir)
        when "cypher"
          Archimate::Export::Cypher.new(output_io).to_cypher(model)
        else
          Archimate.logger.error "Export to '#{export_format}' is not supported yet."
        end
      end
    end
  end
end
