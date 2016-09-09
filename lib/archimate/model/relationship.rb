# frozen_string_literal: true
module Archimate
  module Model
    class Relationship
      attr_reader :id, :name, :type, :parent_xpath, :documentation, :properties, :source, :target

      def initialize(id, type, source, target, name = nil, documentation = [], properties = [])
        @id = id
        @type = type
        @source = source
        @target = target
        @name = name
        @documentation = documentation
        @properties = properties
        @parent_xpath = Archimate::Conversion::ArchiFileFormat::ELEMENT_TYPE_TO_PARENT_XPATH[@type]
      end

      def to_s
        "#{type}<#{id}> #{name} #{source}->#{target} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def ==(other)
        @id == other.id &&
          @name == other.name &&
          @type == other.type &&
          @documentation == other.documentation &&
          @properties == other.properties
      end
    end
  end
end
