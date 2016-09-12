# frozen_string_literal: true
module Archimate
  module Model
    class Diagram
      attr_reader :id
      attr_accessor :name, :documentation, :properties, :children, :viewpoint, :element_references

      def initialize(id, name, viewpoint = nil)
        @id = id
        @name = name
        @viewpoint = viewpoint
        @documentation = []
        @properties = []
        @children = {}
        @element_references = []
        yield self if block_given?
      end
    end
  end
end
