# frozen_string_literal: true
module Archimate
  module Diff
    class Delete < Difference
      attr_accessor :deleted
      attr_accessor :from_model

      alias from deleted
      alias model from_model

      def initialize(path, from_model, val)
        super(path)
        @from_model = from_model
        @deleted = val
      end

      def ==(other)
        super &&
          other.is_a?(Delete) &&
          deleted == other.deleted
      end

      # def <=>(other)
      #   case other
      #   when Insert, Change
      #     1
      #   else
      #     if self == other
      #       0
      #     else
      #       other.path <=> path
      #     end
      #   end
      # end

      def diff_type
        HighLine.color('DELETE:', :delete)
      end

      def to_s
        parent, remaining_path = describeable_parent(from_model)
        s = "#{diff_type} in #{parent}"
        s += " at #{remaining_path.light_blue}: #{from}" unless remaining_path.nil? || remaining_path.empty?
        s
      end

      def to
        nil
      end
    end
  end
end
