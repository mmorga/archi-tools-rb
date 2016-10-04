# frozen_string_literal: true
module Archimate
  module Diff
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

      def initialize
        @conflicts = []
        @base_local_diffs = []
        @base_remote_diffs = []
      end

      def three_way(base, local, remote)
        @base = base
        @local = local
        @remote = remote
        @conflicts = []
        @base_local_diffs = Archimate.diff(base, local)
        @base_remote_diffs = Archimate.diff(base, remote)
        apply_diffs(base_remote_diffs,
                    apply_diffs(base_local_diffs, base.with))
      end

      def two_way(base, local)
        @base = base
        @local = local
        @remote = nil
        @conflicts = []
        @base_local_diffs = Archimate.diff(base, local)
        @base_remote_diffs = []
        apply_diffs(base_local_diffs, base.with)
      end

      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        @conflicts = find_conflicts
        diffs.reject { |diff| @conflicts.flatten.include?(diff) }.inject(model) do |m, diff|
          apply_diff(m, diff.with(entity: diff.entity.split("/")[1..-1].join("/")))
        end
      end

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
        @conflicts = find_diff_entity_conflicts
        @conflicts.concat(find_diagram_delete_update_conflicts)
      end

      def find_diagram_delete_update_conflicts
        local_diagram_updates = base_local_diffs.each_with_object([]) do |i, a|
          a << i.entity if i.entity.match(%r{/diagram/})
        end
        # puts local_diagram_updates.pretty_inspect
        []
      end

      def find_diff_entity_conflicts
        @conflicts = @base_local_diffs.each_with_object([]) do |local_diff, cfx|
          remote_diff_idx = @base_remote_diffs.index { |remote_diff| local_diff.entity == remote_diff.entity }
          cfx << [local_diff, base_remote_diffs[remote_diff_idx]] unless remote_diff_idx.nil?
        end
      end
    end
  end
end
