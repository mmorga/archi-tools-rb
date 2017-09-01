# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module DataModel
    class DiagramType
      include Ruby::Enum

      define :ArchimateDiagramModel, "ArchimateDiagramModel"
      define :SketchModel, "SketchModel"

      def self.===(other)
        values.include?(other)
      end
    end
  end
end
