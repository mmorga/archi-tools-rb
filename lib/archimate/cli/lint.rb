# frozen_string_literal: true

module Archimate
  module Cli
    class Lint
      def initialize(model, output_io)
        @model = model
        @output_io = output_io
      end

      def lint
        Archimate::Lint::Linter.new(@model).report(@output_io)
      end
    end
  end
end
