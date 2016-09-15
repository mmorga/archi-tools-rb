# frozen_string_literal: true
module Archimate
  module Model
    class Relationship
      attr_reader :id, :name, :type, :source, :target
      attr_accessor :documentation, :properties

      def initialize(id, type, source, target, name)
        @id = id
        @type = type
        @source = source
        @target = target
        @name = name
        @documentation = []
        @properties = []
        yield self if block_given?
      end

      def to_s
        "#{type}<#{id}> #{name} #{source} -> #{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def ==(other)
        @id == other.id &&
          @name == other.name &&
          @type == other.type &&
          @source == other.source &&
          @target == other.target &&
          @documentation == other.documentation &&
          @properties == other.properties
      end

      def element_reference
        [@source, @target]
      end
    end
  end
end
