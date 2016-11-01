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
        s = "#{diff_type} in #{parent.describe(model, path: remaining_path, from_model: from_model, from: from, to: to)}"
        s += " at #{remaining_path.light_blue}: " unless remaining_path.empty?
        # s += "#{parent.describe(from, model: from_model, path: remaining_path)} -> " \
        #   "#{parent.describe(to, model: to_model, path: remaining_path)}"
        s
      end
    end
  end
end
