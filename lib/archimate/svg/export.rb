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
        @progress = @aio.create_progressbar(total: model.diagrams.size, title: "Writing SVGs")
        model.diagrams.each do |diagram|
          export(diagram)
          @progress&.increment
        end
      ensure
        @progress&.finish
        @progress = nil
      end

      def export(diagram, file_name = nil)
        file_name ||= diagram.id
        file_name = file_name.strip.tr("/",  "-")
        file_name += ".svg" unless file_name =~ /\.svg$/
        File.open(File.join(@aio.output_dir, file_name), "wb") do |f|
          f.write(Diagram.new(diagram, @aio).to_svg)
        end
      end
    end
  end
end
