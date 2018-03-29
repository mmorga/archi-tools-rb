# frozen_string_literal: true

module Archimate
  module CoreRefinements
    refine String do
      # Converts a mixed case string to a snake case string
      # @return String
      def snake_case
        gsub(/([A-Z])/, '_\1').downcase.sub(/\A_/, "")
      end

      def to_method_name(suffix = nil)
        [tr(' ', '_'), suffix]
          .compact
          .join("_")
          .to_sym
      end

      # A helper that makes it easier to compare a string to a DataModel::LangString
      # @param [String, DataModel::LangString] other string to compare
      # @returns [Boolean]
      def ==(other)
        super(other.to_s)
      end
    end

    refine Range do
      # Returns midpoint of overlap between numeric ranges or nil if there
      # is no overlap
      # @param r [Range] a numeric range
      # @return [Numeric] if the ranges overlap, the midpoint of the overlap
      # @return [Nil] if the ranges do not overlap
      def overlap_midpoint(r)
        begin_max = [self, r].map(&:begin).max
        end_min = [self, r].map(&:end).min
        return nil if begin_max > end_min
        (begin_max + end_min) / 2.0
      end
    end
  end
end
