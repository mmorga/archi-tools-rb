# frozen_string_literal: true
module Archimate
  module Diff
    class Delete < Difference
      attr_accessor :deleted
      attr_accessor :from_model

      alias from deleted

      def initialize(path, from_model, val)
        super(path)
        @from_model = from_model
        @deleted = val
      end

      def ==(other)
        super && @deleted == other.deleted
      end

      def to_s
        "#{HighLine.color('DELETE: ', :red)}#{path}: #{deleted}"
      end
    end
  end
end
