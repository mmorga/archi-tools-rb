# frozen_string_literal: true
module Archimate
  module Diff
    class Change < Difference
      attr_accessor :from_model
      attr_accessor :to_model
      attr_accessor :from
      attr_accessor :to

      alias model to_model

      def initialize(path, from_model, to_model, from, to)
        super(path)
        @from = from
        @to = to
        @from_model = from_model
        @to_model = to_model
      end

      def ==(other)
        super &&
          other.is_a?(Change) &&
          @from == other.from && @to == other.to
      end

      def to_s
        "#{HighLine.color('CHANGE: ', :yellow)}#{path}: #{from} -> #{to}"
      end

      def diff_type
        'CHANGE:'.yellow
      end

      def describe
        to_parent, to_remaining_path = describeable_parent(to_model)
        # from_parent, from_remaining_path = describeable_parent(from_model)
        s = diff_type
        s += to_parent.describe(to_model)
        s += " #{to_remaining_path.light_blue} #{from.light_red} -> #{to.light_green}" unless to_remaining_path.empty?
        s
      end
    end
  end
end
