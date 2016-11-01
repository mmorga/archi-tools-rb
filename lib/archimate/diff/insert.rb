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

      def diff_type
        'INSERT:'.green
      end

      def to_s
        parent, remaining_path = describeable_parent(model)
        s = "#{diff_type} in #{parent.describe(model)}"
        s += " at #{remaining_path.light_blue}: #{model.describe(inserted)}" unless remaining_path.empty?
        s
      end
    end
  end
end
