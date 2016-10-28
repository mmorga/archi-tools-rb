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
        path =~ %r{/elements/([^/]+)$} ? true : false
      end

      def in_element?
        path =~ %r{/elements/([^/]+)/} ? true : false
      end

      def element_id
        m = path.match(%r{/elements/([^/]+)/?})
        m[1] if m
      end

      def in_folder?
        path =~ %r{/folders/([^/]+)/} ? true : false
      end

      def folder_id
        m = path.match(%r{/folders/([^/]+)/?})
        m[1] if m
      end

      def relationship?
        path =~ %r{/relationships/([^/]+)$} ? true : false
      end

      def in_relationship?
        path =~ %r{/relationships/([^/]+)/} ? true : false
      end

      def relationship_id
        m = path.match(%r{/relationships/([^/]+)/?})
        m[1] if m
      end

      def element_and_remaining_path(model)
        m = path.match(%r{/elements/([^/]+)(/?.*)$})
        [model.elements[m[1]], m[2]] if m
      end

      def folder_and_remaining_path(model)
        idx = path.rindex(%r{/folders/([^/]+)(.*)$})
        m = path[idx..-1].match(%r{/folders/([^/]+)(.*)$})
        [model.find_folder(m[1]), m[2]] if m
      end

      def relationship_and_remaining_path(model)
        m = path.match(%r{/relationships/([^/]+)(/?.*)$})
        [model.relationships[m[1]], m[2]] if m
      end

      def diagram_and_remaining_path(model)
        m = path.match(%r{/diagrams/([^/]+)(/?.*)$})
        [model.diagrams[m[1]], m[2]] if m
      end

      def model_and_remaining_path(model)
        m = path.match(%r{^Model<[^\]]*>(/?.*)$})
        [model, m[1]] if m
      end

      def describeable_parent(model)
        if in_element?
          element_and_remaining_path(model)
        elsif in_folder?
          folder_and_remaining_path(model)
        elsif in_relationship?
          relationship_and_remaining_path(model)
        elsif in_diagram?
          diagram_and_remaining_path(model)
        else
          model_and_remaining_path(model)
        end
      end
    end
  end
end
