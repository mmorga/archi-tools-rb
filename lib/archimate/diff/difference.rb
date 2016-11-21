# frozen_string_literal: true
module Archimate
  module Diff
    # Difference defines a change between two entities within a model
    # * change kind (delete, insert, change)
    # * path (reference to the path or attribute)
    # * from (invalid for insert)
    # * to (invalid for delete)
    # TODO: I really need to have the from value - idx isn't enough to make sure when applying diffs
    class Difference
      attr_accessor :path # TODO: path is accessed as a stack, consider changing from string to stack

      def initialize(path)
        raise "Instantiating abstract Difference" if self.class == Difference
        @path = path
        @array_re = Regexp.compile(/\[(\d+)\]/)
        yield self if block_given?
      end

      def with(options = {})
        diff = dup
        diff.path = options.fetch(:path, path)
        diff
      end

      def ==(other)
        return false unless other.is_a?(Difference)
        @path == other.path
      end

      # Difference sorting is based on the path.
      # Top level components are sorted in this order: (elements, relationships, diagrams, folders)
      # Array entries are sorted by numeric order
      # Others are sorted alphabetically
      def <=>(other)
        top_order = %w(elements relationships diagrams folders)
        a = path_to_array
        b = other.path_to_array

        res = top_order.index(a.shift) <=> top_order.index(b.shift)
        return res unless res.zero?

        # a needs to be at least as long as b to get the zip behavior I want
        a.push(nil) while a.size < b.size
        # a, b = [a, b].sort { |x, y| y.size <=> x.size }
        a.zip(b).each do |pa, pb|
          return -1 if pb.nil?
          return 1 if pa.nil?
          res = pa <=> pb
          return res unless res.zero?
        end
        0
      end

      def path_to_array
        path.split("/")[1..-1].map do |p|
          md = @array_re.match(p)
          md ? md[1].to_i : p
        end
      end

      def array?
        path =~ /\[\d+\]$/
      end

      # Returns true if this diff is for a diagram (not a part within a diagram)
      def diagram?
        path =~ %r{/diagrams/\[(\d+)\]$} ? true : false
      end

      def diagram_idx
        m = path.match(%r{/diagrams/\[(\d+)\]/?})
        m[1].to_i if m
      end

      def in_diagram?
        path =~ %r{/diagrams/\[(\d+)\]/}
      end

      def element?
        path =~ %r{/elements/\[(\d+)\]$} ? true : false
      end

      def in_element?
        path =~ %r{/elements/\[(\d+)\]/} ? true : false
      end

      def element_idx
        m = path.match(%r{/elements/\[(\d+)\]/?})
        m[1].to_i if m
      end

      def in_folder?
        path =~ %r{/folders/\[(\d+)\]/} ? true : false
      end

      def relationship?
        path =~ %r{/relationships/\[(\d+)\]$} ? true : false
      end

      def in_relationship?
        path =~ %r{/relationships/\[(\d+)\]/} ? true : false
      end

      def relationship_idx
        m = path.match(%r{/relationships/\[(\d+)\]/?})
        m[1].to_i if m
      end

      def relationship
        model.relationships[relationship_idx] if relationship?
      end

      def element
        model.elements[element_idx] if element?
      end

      def element_and_remaining_path(model)
        m = path.match(%r{/elements/\[(\d+)\](/?.*)$})
        [model.elements[m[1].to_i], m[2]] if m
      end

      def folder_and_remaining_path(model)
        re = Regexp.compile(%r{/folders/\[(\d+)\]})
        folder_parts = path.split(re).reject(&:empty?)
        folder_parts.shift # Throw away leading parts
        remaining_path = folder_parts.pop
        folder_parts = folder_parts.map(&:to_i)

        folder = model
        folder = folder.folders[folder_parts.shift] until folder_parts.empty?
        [folder, remaining_path]
      end

      def relationship_and_remaining_path(model)
        m = path.match(%r{/relationships/\[(\d+)\](/?.*)$})
        [model.relationships[m[1].to_i], m[2]] if m
      end

      def diagram_and_remaining_path(model)
        m = path.match(%r{/diagrams/\[(\d+)\](/?.*)$})
        [model.diagrams[m[1].to_i], m[2]] if m
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

      def delete?
        is_a?(Delete)
      end

      def change?
        is_a?(Change)
      end

      def insert?
        is_a?(Insert)
      end
    end
  end
end
