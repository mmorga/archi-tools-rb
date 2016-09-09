# frozen_string_literal: true
module Archimate
  module Model
    class Model
      attr_accessor :id, :name, :documentation, :properties, :elements, :organization, :relationships

      def initialize(id = nil, name = nil, documentation = [], properties = [], elements = {}, organization = [], relationships = [])
        @id = id
        @name = name
        @documentation = documentation
        @properties = properties
        @elements = elements
        @organization = organization
        @relationships = relationships
        yield self if block_given?
      end
    end
  end
end
