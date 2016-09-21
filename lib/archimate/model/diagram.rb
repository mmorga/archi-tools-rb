# frozen_string_literal: true
module Archimate
  module Model
    class Diagram
      ATTRS = [:id, :name, :documentation, :properties, :children, :viewpoint, :element_references].freeze

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

      def ==(other)
        ATTRS.all? { |sym| send(sym) == other.send(sym) }
      end

      def hash
        ATTRS.each_with_object(self.class.hash) { |i, a| a ^ send(i).send(:hash) }
      end

      def dup(id: nil, name: nil, viewpoint: nil)
        Diagram.new(id || @id, name || @name, viewpoint || @viewpoint) do |d|
          ATTRS.reject { |a| [:id, :name, :viewpoint].include?(a) }.each do |sym|
            d.send("#{s}=".to_sym, send(sym).dup)
          end
        end
      end
    end
  end
end
