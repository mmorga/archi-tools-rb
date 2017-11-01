# frozen_string_literal: true

require "ruby-enum"

module Archimate
  module DataModel
    class Layer
      attr_reader :name
      attr_reader :background_class

      # No user serviceable parts here. don't use me.
      def initialize(layer = "None", background_class = "")
        @symbol = Layer.symbolize(layer)
        @name = layer
        @background_class = background_class
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

      def self.symbolize(str)
        return str if str.is_a?(Symbol)
        str.downcase.tr(" ", "_").to_sym
      end
    end
  end
end
