# frozen_string_literal: true
module Archimate
  module Cli
    class Lint
      def initialize(io = AIO.new)
        @io = io
      end

      def lint
        return unless @io.output_io
        return if @io.model.nil?
        model = @io.model
        output = @io.output_io

        Archimate::Lint::Linter.new(model).report(output)
      end
    end
  end
end
