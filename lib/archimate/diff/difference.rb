# frozen_string_literal: true
module Archimate
  module Diff
    # Difference defines a change between two entities within a model
    # * change kind (delete, insert, change)
    # * entity (reference to the entity or attribute)
    # * parent (reference to the entity (an element with an id) parent)
    # * from (invalid for insert)
    # * to (invalid for delete)
    # * index (for items in a list, the index of the item)
    class Difference
      KIND = [:delete, :insert, :change].freeze

      attr_reader :kind
      attr_accessor :entity
      attr_accessor :parent
      attr_accessor :from
      attr_accessor :to
      attr_accessor :index

      def self.context(entity, parent = nil)
        new(nil, entity, parent)
      end

      def self.delete(from, entity = nil, parent = nil, index = nil)
        del = new(:delete, entity) do |d|
          d.parent = parent
          d.from = from
          d.index = index
        end
        yield del if block_given?
        del
      end

      def self.insert(to, entity = nil, parent = nil, index = nil)
        ins = new(:insert, entity) do |d|
          d.parent = parent
          d.to = to
          d.index = index
        end
        yield ins if block_given?
        ins
      end

      def self.change(from, to, entity = nil, parent = nil, index = nil)
        diff = new(:change, entity) do |d|
          d.parent = parent
          d.from = from
          d.to = to
          d.index = index
        end
        yield diff if block_given?
        diff
      end

      def initialize(kind, entity, parent = nil, from = nil, to = nil, index = nil)
        @kind = kind
        @entity = entity
        @parent = parent
        @from = from
        @to = to
        @index = index
        yield self if block_given?
      end

      def apply(diffs)
        diffs.map do |d|
          diff = d.dup
          diff.entity = entity
          diff.parent = parent
          diff
        end
      end

      def ==(other)
        return false unless other.is_a?(Difference)
        @kind == other.kind &&
          @entity == other.entity &&
          @parent == other.parent &&
          @from == other.from &&
          @to == other.to &&
          @index == other.index
      end

      def to_s
        "#{fmt_kind}#{maybe_parent_to_s}#{maybe_index_to_s}#{entity_str}#{diff_description}"
      end

      def maybe_parent_to_s
        parent.nil? ? "" : "#{parent} > "
      end

      def maybe_index_to_s
        ""
        # index.nil? ? "" : " [#{index}] "
      end

      def fmt_kind
        case kind
        when :delete
          HighLine.color("DELETE: ", :red)
        when :insert
          HighLine.color("INSERT: ", :green)
        else
          HighLine.color("CHANGE: ", :yellow)
        end
      end

      def entity_str
        s = entity.to_s
        s += "[#{index}]" unless index.nil?
        s
      end

      def diff_description
        case kind
        when :delete
          ""
        when :insert
          ""
        else
          ": #{from} -> #{to}"
        end
      end
    end
  end
end
