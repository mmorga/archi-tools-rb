# frozen_string_literal: true
module Archimate
  module Svg
    class Export
      attr_reader :model

      def initialize(model, aio)
        @model = model
        @aio = aio
      end

      def export_all
        model.diagrams.each do |diagram|
          export(diagram)
        end
      end

      def export(diagram, file_name = nil)
        file_name ||= diagram.name
        file_name.tr!("/",  "-")
        file_name += ".svg" unless file_name =~ /\.svg$/
        File.open(File.join(@aio.output_dir, file_name), "wb") do |f|
          f.write(Diagram.new(diagram, @aio).to_svg)
        end
      end
    end
  end
end
