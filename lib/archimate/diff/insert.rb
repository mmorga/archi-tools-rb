# frozen_string_literal: true
module Archimate
  module Diff
    class Insert < Difference
      attr_accessor :inserted
      attr_accessor :to_model

      alias to inserted
      alias model to_model

      def initialize(path, to_model, inserted)
        super(path)
        @inserted = inserted
        @to_model = to_model
      end

      def ==(other)
        super &&
          other.is_a?(Insert) &&
          inserted == other.inserted
      end

      # def <=>(other)
      #   case other
      #   when Change
      #     1
      #   when Delete
      #     -1
      #   else
      #     if self == other
      #       0
      #     else
      #       other.path <=> path
      #     end
      #   end
      # end

      def diff_type
        HighLine.color('INSERT:', :insert)
      end

      def to_s
        parent, remaining_path = describeable_parent(model)
        s = "#{diff_type} in #{parent}"
        s += " at #{HighLine.color(remaining_path, :path)}: #{inserted}" unless remaining_path.nil? || remaining_path.empty?
        s
      end
    end
  end
end
