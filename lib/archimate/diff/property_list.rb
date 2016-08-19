# frozen_string_literal: true
module Archimate
  module Diff
    class PropertyList
      attr_reader :properties

      def initialize(node_set)
        @properties = node_set.each_with_object([]) { |i, a| a << [i.attr("key"), i.attr("value")] }
      end

      def size
        @properties.size
      end

      def ==(other)
        @properties.size == other.size &&
          @properties.each_with_index { |p, i| p[0] == other.properties[i][0] && p[1] == other.properties[i][1] }
      end
    end
  end
end
