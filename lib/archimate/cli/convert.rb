# frozen_string_literal: true
module Archimate
  module Cli
    class Convert
      SUPPORTED_FORMATS = %w(meff2.1 archi nquads graphml csv).freeze

      def initialize(io = AIO.new)
        @io = io
      end

      def convert(export_format)
        return unless @io.output_io
        return if @io.model.nil?
        model = @io.model
        output = @io.output_io

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
          Archimate::Export::CSVExport.new(model).to_csv(output_dir: @io.output_dir)
        else
          @io.error "Export to '#{export_format}' is not supported yet."
        end
      end
    end
  end
end
