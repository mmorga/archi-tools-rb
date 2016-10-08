# frozen_string_literal: true
module Archimate
  module Diff
    require 'forwardable'

    class Conflicts
      extend Forwardable
      attr_reader :conflicts

      def_delegator :@conflicts, :empty?
      def_delegator :@conflicts, :size
      def_delegator :@conflicts, :first

      def initialize
        @conflicts = []
        @cwhere = {}
      end

      def <<(conflict)
        conflict_ary = Array(conflict)
        # TODO: remove this - it's for testing/debug only
        raise TypeError, "Must be a Conflict was a '#{conflict.class}'" unless conflict_ary.all? { |i| i.is_a?(Archimate::Diff::Conflict) }
        # TODO: remove this block - it's for debug only
        conflict_ary.each { |c| raise ArgumentError, "Trying to add a duplicate conflict #{c} into #{self}" if conflicts.include?(c) }
        conflicts.concat(conflict_ary)
        self
      end

      def diffs
        conflicts.map(&:diffs).flatten
      end

      def filter_diffs(diff_list)
        conflict_diffs = diffs
        diff_list.reject { |diff| conflict_diffs.include?(diff) }
      end

      def to_s
        "Conflicts\n\t#{conflicts.map(&:to_s).join("\n\t")}\n"
      end
    end

    # So it could be that if an item is deleted from 1 side
    # then it's actually the result of a de-duplication pass.
    # If so, then we could get good results by de-duping the
    # new side and comparing the results.
    class Merge
      attr_reader :conflicts
      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs
      attr_reader :base
      attr_reader :local
      attr_reader :remote
      attr_reader :merged

      def initialize(base, local, remote)
        @base = base
        @local = local
        @remote = remote
        @merged = base
        @conflicts = Conflicts.new
        @base_local_diffs = []
        @base_remote_diffs = []
      end

      def self.three_way(base, local, remote)
        merge = Merge.new(base, local, remote)
        merge.three_way
        merge
      end

      def three_way
        @base_local_diffs = Archimate.diff(base, local)
        @base_remote_diffs = Archimate.diff(base, remote)
        find_conflicts
        @merged = apply_diffs(
          base_remote_diffs,
          apply_diffs(base_local_diffs, base.with)
        )
      end

      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        conflicts.filter_diffs(diffs).inject(model) do |m, diff|
          apply_diff(m, diff.with(entity: diff.entity.split("/")[1..-1].join("/")))
        end
      end

      # This is in need of refactoring
      def apply_diff(node, diff)
        path = diff.entity.split("/")
        attr_name = path.shift.to_sym
        raise "Name Error: #{path.first}" unless node.class.schema.include?(attr_name.to_sym)

        if path.empty?
          # Intention here is to handle simple types like string, integer
          node.with(attr_name => diff.to)
        else
          # TODO: may need to handle complex object here (other than collection)
          child_collection = node.send(attr_name)
          id = path.shift
          # Note: if the path is empty at this point, there's no more need to drill down
          if path.empty?
            if diff.delete?
              node.with(attr_name => child_collection.reject { |_k, v| v == diff.from })
            else
              apply_child_changes(node, attr_name, id, diff.to)
            end
          else
            id = id.to_i if child_collection.is_a? Array
            child = child_collection[id]
            raise "Child #{id} not found in collection" if child.nil?
            apply_child_changes(node, attr_name, id, apply_diff(child, diff.with(entity: path.join("/"))))
          end
        end
      end

      # TODO: this is a little hokey. I'd like to basically call a diff method based on the
      # type of the child collection here.
      def apply_child_changes(node, attr_name, id, child_value)
        child_collection = node.send(attr_name)
        case child_collection
        when Hash
          node.with(attr_name => child_collection.merge(id => child_value))
        when Array
          id = id.to_i
          nu_collection = child_collection.dup
          nu_collection[id.to_i] = child_value
          node.with(attr_name => nu_collection)
        else
          raise "Type Error #{child_collection.class} unexpected for collection type"
        end
      end

      # TODO: if we're looking at an Array, a conflict can be resolved by inserting both.
      def find_conflicts
        conflicts << find_diff_entity_conflicts
        conflicts << find_diagram_delete_update_conflicts
      end

      # Returns the set of conflicts caused by one diff set deleting a diagram
      # that the other diff set shows updated. This means that the diagram
      # probably shouldn't be deleted.
      #
      # TODO: should this be some other class?
      def find_diagram_delete_update_conflicts
        [base_local_diffs, base_remote_diffs].permutation(2).each_with_object([]) do |(diffs1, diffs2), a|
          a.concat(
            diagram_diffs_in_conflict(
              Difference.diagram_deleted_diffs(diffs1),
              Difference.diagram_updated_diffs(diffs2)
            )
          )
        end
      end

      # we want to make a Conflict for each parent_diff and set of child_diffs with the same diagram_id
      def diagram_diffs_in_conflict(parent_diffs, child_diffs)
        parent_diffs.each_with_object([]) do |parent_diff, a|
          conflicting_child_diffs = child_diffs.select { |child_diff| parent_diff.diagram_id == child_diff.diagram_id }
          a << Conflict.new(
            # TODO: we need a context here to know if it's a base to remote or remote to base conflict
            parent_diff, conflicting_child_diffs, "Diagram deleted in one change set modified in another"
          ) unless conflicting_child_diffs.empty?
        end
      end

      def find_diff_entity_conflicts
        @base_local_diffs.each_with_object([]) do |local_diff, cfx|
          conflicting_remote_diffs = @base_remote_diffs.select { |remote_diff| local_diff.entity == remote_diff.entity }
          cfx << Conflict.new(
            local_diff,
            conflicting_remote_diffs,
            "Conflicting changes"
          ) unless conflicting_remote_diffs.empty?
        end
      end
    end
  end
end
