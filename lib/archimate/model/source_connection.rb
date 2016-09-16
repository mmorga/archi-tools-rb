module Archimate
  module Model
    class SourceConnection
      attr_reader :id
      attr_accessor :type, :source, :target, :relationship, :bendpoints

      def initialize(id)
        @id = id
        yield self if block_given?
      end

      def ==(other)
        @id == other.id &&
          @type == other.type &&
          @source == other.source &&
          @target == other.target &&
          @relationship == other.relationship &&
          @bendpoints == other.bendpoints
      end

      def hash
        self.class.hash ^
          @id.hash ^
          @type.hash ^
          @source.hash ^
          @target.hash ^
          @relationship.hash ^
          @bendpoints.hash
      end
    end
  end
end
