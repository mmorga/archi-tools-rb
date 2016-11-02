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

      def diff_type
        'CHANGE:'.yellow
      end

      def to_s
        parent, remaining_path = describeable_parent(from_model)
        s = "#{diff_type} in #{parent}"
        s += " at #{remaining_path.light_blue}" unless remaining_path.empty?
        s += " #{from} -> #{to}"
        s
      end
    end
  end
end
