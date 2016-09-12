# frozen_string_literal: true
module Archimate
  module Model
    class Property
      attr_reader :key, :value

      def initialize(key, value)
        @key = key
        @value = value
      end

      def ==(other)
        @key == other.key &&
          @value == other.value
      end
    end
  end
end
