# frozen_string_literal: true
module Archimate
  module Diff
    class Difference
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive
      extend Forwardable

      ARRAY_RE = Regexp.compile(/\[(\d+)\]/)
      PATH_ROOT_SORT_ORDER = %w(elements relationships diagrams folders).freeze

      attr_reader :target
      attr_reader :changed_from
      attr_reader :sub_path

      def_delegator :@target, :path

      # Re-thinking.
      #
      # Requirements:
      #
      # 1. User friendly display of what is different in context
      # 2. Able to apply the diff to another model (which was based on the "base" of the diff)
      #
      # Delete:                         example
      #   ArchimateNode                 child.bounds
      #   ArchimateNode, attribute      model, "name"
      #   DiffableArray, ArchimateNode  model.elements, element
      #   bendpoint attributes under source_connection
      #                                 documentation
      #                                 properties
      #                                 child/style/fill_color
      #                                 child/style/font/name
      #
      # @param target [Dry::Struct with id attribute] the element operated on (why is array treated as a special case?)
      # @param changed_from [same class as target] (optional) for change this is the previous value
      # def initialize(changed_from, target)
      def initialize(target, changed_from = nil)
        raise TypeError, "Expected target to be an ArchimateNodeReference" unless target.is_a?(ArchimateNodeReference)
        raise "Instantiating abstract Difference" if self.class == Difference
        @target = target
        @changed_from = changed_from
      end

      def ==(other)
        other.is_a?(self.class) &&
          @target == other.target &&
          @changed_from == other.changed_from
      end

      # Difference sorting is based on the path.
      # Top level components are sorted in this order: (elements, relationships, diagrams, folders)
      # Array entries are sorted by numeric order
      # Others are sorted alphabetically
      def <=>(other)
        a = path_to_array
        b = other.path_to_array

        part_a = a.shift
        part_b = b.shift
        res = PATH_ROOT_SORT_ORDER.index(part_a) <=> PATH_ROOT_SORT_ORDER.index(part_b)
        return res unless res.zero?

        until a.empty? || b.empty?
          part_a = a.shift
          part_b = b.shift

          return part_a <=> part_b unless (part_a <=> part_b).zero?
        end

        return -1 if a.empty?
        return 1 if b.empty?
        part_a <=> part_b
      end

      def delete?
        false
      end

      def change?
        false
      end

      def insert?
        false
      end

      def path_to_array
        path(force_array_index: :index).split("/").map do |p|
          md = ARRAY_RE.match(p)
          md ? md[1].to_i : p
        end
      end

      def summary_element
        summary_elements = [DataModel::Element, DataModel::Folder, DataModel::Relationship, DataModel::Diagram, DataModel::Model]
        se = target.value.primitive? ? target.parent : target.value
        se = se.parent while summary_elements.none? { |c| se.is_a?(c) }
        se
      end
    end
  end
end
