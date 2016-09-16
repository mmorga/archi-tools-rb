# frozen_string_literal: true
module Archimate
  module Model
    class Relationship
      attr_reader :id, :name, :type, :source, :target
      attr_accessor :documentation, :properties

      def self.copy(relationship, id: nil, name: nil, type: nil, source: nil, target: nil, documentation: nil, properties: nil)
        rel = relationship.dup
        rel.instance_variable_set(:@id, id) unless id.nil?
        rel.instance_variable_set(:@name, name) unless name.nil?
        rel.instance_variable_set(:@type, type) unless type.nil?
        rel.instance_variable_set(:@source, source) unless source.nil?
        rel.instance_variable_set(:@target, target) unless target.nil?
        rel.instance_variable_set(:@documentation, documentation) unless documentation.nil?
        rel.instance_variable_set(:@properties, properties) unless properties.nil?
        rel
      end

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
