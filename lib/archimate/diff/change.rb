module Archimate
  module Diff
    class Change
      attr_reader :kind, :location, :subject

      def initialize(kind, subject)
        @kind = kind
        @subject = subject
      end

      def ==(other)
        return false unless other.is_a?(Change)
        @kind == other.kind &&
          @subject == other.subject
      end
    end
  end
end
