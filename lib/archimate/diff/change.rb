# frozen_string_literal: true
module Archimate
  module Diff
    class Change < Difference
      attr_accessor :from_model
      attr_accessor :to_model
      attr_accessor :from
      attr_accessor :to

      def initialize(path, from_model, to_model, from, to)
        super(path)
        @from = from
        @to = to
        @from_model = from_model
        @to_model = to_model
      end

      def ==(other)
        super && @from == other.from && @to == other.to
      end

      def to_s
        "#{HighLine.color('CHANGE: ', :yellow)}#{path}: #{from} -> #{to}"
      end
    end
  end
end
