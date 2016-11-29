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

      # def <=>(other)
      #   case other
      #   when Insert, Delete
      #     -1
      #   else
      #     if self == other
      #       0
      #     else
      #       path <=> other.path
      #     end
      #   end
      # end

      def diff_type
        HighLine.color('CHANGE:', :change)
      end

      def to_s
        parent, remaining_path = describeable_parent(from_model)
        s = "#{diff_type} in #{parent}"
        s += " at #{HighLine.color(remaining_path, :path)}" unless remaining_path.nil? || remaining_path.empty?
        s += " #{from} -> #{to}"
        s
      end
    end
  end
end
