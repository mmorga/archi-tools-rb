# frozen_string_literal: true
module Archimate
  module Diff
    # Big plans for the Difference class
    # Consider converting to a Value object under DataModel
    # - To do so will require making the to and from attributes type safe
    # - So they'd need to be different Values by types
    # - Also consider different types for the KIND enum

    # Difference defines a change between two entities within a model
    # * change kind (delete, insert, change)
    # * entity (reference to the entity or attribute)
    # * from (invalid for insert)
    # * to (invalid for delete)
    class Difference
      # TODO:consider adding a "conflict difference kind"
      KIND = [:delete, :insert, :change].freeze

      attr_reader :kind
      attr_accessor :entity # TODO: entity is accessed as a stack, consider changing from string to stack
      # TODO: would be nice if reference to the object is here too.
      # TODO: this is really a path an XPATH (or JSONPath) expression would be a nice way to keep this associated with a particular object.
      attr_accessor :from
      attr_accessor :to

      def self.context(entity)
        new(nil, entity)
      end

      def self.delete(entity, val)
        del = new(:delete, entity) do |d|
          d.from = val
        end
        yield del if block_given?
        del
      end

      def self.insert(entity, to)
        ins = new(:insert, entity) do |d|
          d.to = to
        end
        yield ins if block_given?
        ins
      end

      def self.change(entity, from, to)
        diff = new(:change, entity) do |d|
          d.from = from
          d.to = to
        end
        yield diff if block_given?
        diff
      end

      # Returns the list of diffs for diagrams referenced in the given diff set
      def self.diagram_differences(diffs)
        diffs.select(&:in_diagram?)
      end

      def self.diagram_deleted_diffs(diffs)
        diffs.select { |i| i.delete? && i.diagram? }
      end

      def self.diagram_updated_diffs(diffs)
        diffs.select(&:in_diagram?)
      end

      def initialize(kind, entity)
        @kind = kind
        @entity = entity
        @from = from
        @to = to
        yield self if block_given?
      end

      def apply(diffs)
        diffs.map do |d|
          diff = d.dup
          diff.entity = entity
          diff
        end
      end

      def with(options = {})
        Difference.new(
          options.fetch(:kind, kind),
          options.fetch(:entity, entity)
        ) do |diff|
          diff.from = options.fetch(:from, from)
          diff.to = options.fetch(:to, to)
        end
      end

      def ==(other)
        return false unless other.is_a?(Difference)
        @kind == other.kind &&
          @entity == other.entity &&
          @from == other.from &&
          @to == other.to
      end

      def insert?
        kind == :insert
      end

      def delete?
        kind == :delete
      end

      def change?
        kind == :change
      end

      def on_array?
        entity =~ /\[\d+\]$/
      end

      # Returns true if this diff is for a diagram (not a part within a diagram)
      def diagram?
        entity =~ %r{/diagrams/([^/]+)$} ? true : false
      end

      def diagram_id
        m = entity.match(%r{/diagrams/([^/]+)/?})
        m[1] if m
      end

      def in_diagram?
        entity =~ %r{/diagrams/([^/]+)/}
      end

      def element?
        entity =~  %r{/elements/([^/]+)$} ? true : false
      end

      def in_element?
        entity =~  %r{/elements/([^/]+)/} ? true : false
      end

      def element_id
        m = entity.match(%r{/elements/([^/]+)/?})
        m[1] if m
      end

      def relationship?
        entity =~ %r{/relationships/([^/]+)$} ? true : false
      end

      def relationship_id
        m = entity.match(%r{/relationships/([^/]+)/?})
        m[1] if m
      end

      def to_s
        "#{fmt_kind}#{entity}: #{diff_description}"
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

      def diff_description
        case kind
        when :delete
          from.to_s
        when :insert
          to.to_s
        else
          "#{from} -> #{to}"
        end
      end
    end
  end
end
