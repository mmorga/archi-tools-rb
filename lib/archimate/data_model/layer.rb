# frozen_string_literal: true
require "ruby-enum"

module Archimate
  module DataModel
    class Layer
      attr_reader :elements
      attr_reader :name

      # No user serviceable parts here. don't use me.
      def initialize(layer = "None", element_names = [])
        @symbol = Layer.symbolize(layer)
        @name = layer
        @elements = element_names
      end

      def hash
        self.class.hash ^ @symbol.hash
      end

      def ===(other)
        return true if equal?(other)
        case other
        when String
          @symbol == Layer.symbolize(other)
        when Symbol
          @symbol == other
        when Layer
          self == other
        else
          false
        end
      end

      def ==(other)
        @symbol == other&.to_sym
      end

      def to_sym
        @symbol
      end

      def to_s
        @name
      end

      private

      def self.symbolize(str)
        return str if str.is_a?(Symbol)
        str.downcase.tr(" ", "_").to_sym
      end
    end
  end
end
