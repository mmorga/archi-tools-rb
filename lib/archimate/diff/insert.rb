# frozen_string_literal: true
module Archimate
  module Diff
    class Insert < Difference
      attr_accessor :inserted
      attr_accessor :to_model

      alias to inserted

      def initialize(path, to_model, inserted)
        super(path)
        @inserted = inserted
        @to_model = to_model
      end

      def ==(other)
        super && inserted == other.inserted
      end

      def to_s
        "#{HighLine.color('INSERT: ', :green)}#{path}: #{inserted}"
      end
    end
  end
end
