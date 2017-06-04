# frozen_string_literal: true

module Archimate
  module Cli
    class Convert
      include Archimate::Logging

      SUPPORTED_FORMATS = %w[meff2.1 archi nquads graphml csv cypher].freeze

      attr_reader :model

      def initialize(model)
        @model = model
      end

      def convert(export_format, output_io, output_dir)
        return unless output_io && model
        case export_format
        when "archi"
          Archimate::FileFormats::ArchiFileWriter.new(model).write(output_io)
        when "meff2.1"
          Archimate::FileFormats::ModelExchangeFileWriter.new(model).write(output_io)
        when "nquads"
          output_io.write(Archimate::Export::NQuads.new(model).to_nq)
        when "graphml"
          output_io.write(Archimate::Export::GraphML.new(model).to_graphml)
        when "csv"
          Archimate::Export::CSVExport.new(model).to_csv(output_dir: output_dir)
        when "cypher"
          Archimate::Export::Cypher.new(output_io).to_cypher(model)
        else
          error { "Export to '#{export_format}' is not supported yet." }
        end
      end
    end
  end
end
