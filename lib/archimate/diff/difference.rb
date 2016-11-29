# frozen_string_literal: true
module Archimate
  module Diff
    class Difference
      using DataModel::DiffableArray

      ARRAY_RE = Regexp.compile(/\[(\d+)\]/)

      attr_reader :from_element
      attr_reader :to_element
      attr_reader :sub_path

      def initialize(from_element, to_element, sub_path)
        raise "Instantiating abstract Difference" if self.class == Difference
        @from_element = from_element
        @to_element = to_element
        @sub_path = sub_path.nil? ? "" : sub_path.to_s
      end

      def ==(other)
        other.is_a?(self.class) &&
          @from_element == other.from_element &&
          @to_element == other.to_element &&
          @sub_path == other.sub_path
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
        a.zip(b).each do |pa, pb|
          return -1 if pb.nil?
          return 1 if pa.nil?
          res = pa <=> pb
          return res unless res.zero?
        end
        0
      end

      def path
        [
          effective_element&.path,
          sub_path
        ].compact.reject(&:empty?).join("/")
      end

      def path_to_array
        path.split("/").map do |p|
          md = ARRAY_RE.match(p)
          md ? md[1].to_i : p
        end
      end

      def effective_element
        to_element || from_element
      end

      def array?
        sub_path =~ /\[\d+\]$/
      end

      # Returns true if this diff is for a diagram (not a part within a diagram)
      def diagram?
        item_type?(DataModel::Diagram)
      end

      def in_diagram?
        in_item_type?(DataModel::Diagram)
      end

      def element?
        item_type?(DataModel::Element)
      end

      def in_element?
        in_item_type?(DataModel::Element)
      end

      def in_folder?
        in_item_type?(DataModel::Folder)
      end

      def relationship?
        item_type?(DataModel::Relationship)
      end

      def in_relationship?
        in_item_type?(DataModel::Relationship)
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

      def to_value
        sub_path.empty? ? to_element : to_element.send(:[], to_element.is_a?(Array) ? sub_path.to_i : sub_path)
      end

      private

      # What was different
      def what(el)
        sub_path.empty? ? el.to_s : HighLine.color(sub_path, :path)
      end

      # Item the value was inserted into
      def to
        element_parent(to_element)
      end

      # Item the value was deleted from
      def from
        element_parent(from_element)
      end

      def element_parent(el)
        if sub_path.empty?
          p = el.parent
          p.parent if p.is_a?(Array)
        else
          el
        end
      end

      def item_type?(klass)
        sub_path.empty? && effective_element&.is_a?(klass)
      end

      def in_item_type?(klass)
        !sub_path.empty? && effective_element&.is_a?(klass)
      end
    end
  end
end
