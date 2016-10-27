# frozen_string_literal: true
module Archimate
  module Diff
    # Difference defines a change between two entities within a model
    # * change kind (delete, insert, change)
    # * path (reference to the path or attribute)
    # * from (invalid for insert)
    # * to (invalid for delete)
    class Difference
      attr_accessor :path # TODO: path is accessed as a stack, consider changing from string to stack

      def initialize(path)
        raise "Instantiating abstract Difference" if self.class == Difference
        @path = path
        yield self if block_given?
      end

      def apply(diffs)
        diffs.map do |d|
          diff = d.dup
          diff.path = path
          diff
        end
      end

      def with(options = {})
        diff = dup
        diff.path = options.fetch(:path, path)
        # diff.from = options.fetch(:from, from)
        # diff.to = options.fetch(:to, to)
        diff
      end

      def ==(other)
        return false unless other.is_a?(Difference)
        @path == other.path
      end

      def array?
        path =~ /\[\d+\]$/
      end

      # Returns true if this diff is for a diagram (not a part within a diagram)
      def diagram?
        path =~ %r{/diagrams/([^/]+)$} ? true : false
      end

      def diagram_id
        m = path.match(%r{/diagrams/([^/]+)/?})
        m[1] if m
      end

      def in_diagram?
        path =~ %r{/diagrams/([^/]+)/}
      end

      def element?
        path =~  %r{/elements/([^/]+)$} ? true : false
      end

      def in_element?
        path =~  %r{/elements/([^/]+)/} ? true : false
      end

      def element_id
        m = path.match(%r{/elements/([^/]+)/?})
        m[1] if m
      end

      def relationship?
        path =~ %r{/relationships/([^/]+)$} ? true : false
      end

      def relationship_id
        m = path.match(%r{/relationships/([^/]+)/?})
        m[1] if m
      end
    end
  end
end
