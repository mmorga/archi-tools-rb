# frozen_string_literal: true
module Archimate
  module Model
    class Relationship
      attr_reader :id, :name, :type, :parent_xpath, :source, :target
      attr_accessor :documentation, :properties

      def initialize(id, type, source, target, name)
        @id = id
        @type = type
        @source = source
        @target = target
        @name = name
        @documentation = []
        @properties = []
        @parent_xpath = Archimate::Conversion::ArchiFileFormat::ELEMENT_TYPE_TO_PARENT_XPATH[@type]
        yield self if block_given?
      end

      def to_s
        "#{type}<#{id}> #{name} #{source} -> #{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def ==(other)
        @id == other.id &&
          @name == other.name &&
          @type == other.type &&
          @documentation == other.documentation &&
          @properties == other.properties
      end

      def element_reference
        [@source, @target]
      end
    end
  end
end
