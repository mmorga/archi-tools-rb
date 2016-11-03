# frozen_string_literal: true

module Archimate
  module Diff
    # So it could be that if an item is deleted from 1 side
    # then it's actually the result of a de-duplication pass.
    # If so, then we could get good results by de-duping the
    # new side and comparing the results.
    # TODO: Refactor notes. Split this up, three things happening here:
    # 1. Merge
    # 2. Find Conflicts
    # 3. Apply Diffs to Model
    class Merge
      attr_reader :conflicts
      attr_reader :base_local_diffs
      attr_reader :base_remote_diffs
      attr_reader :base
      attr_reader :local
      attr_reader :remote
      attr_reader :merged
      attr_reader :aio
      attr_reader :all_diffs

      def initialize(base, local, remote, aio)
        # @merged = DeepClone.clone base
        @merged = base.clone
        @base = base
        @local = local
        @remote = remote
        @conflicts = Conflicts.new(aio)
        @base_local_diffs = []
        @base_remote_diffs = []
        @aio = aio
      end

      # TODO: refactor message_io should be an AIO not an IO. EIEIO.
      def self.three_way(base, local, remote, aio)
        merge = Merge.new(base, local, remote, aio)
        merge.three_way
        merge
      end

      def three_way
        aio.debug "Computing base:local diffs"
        @base_local_diffs = Archimate.diff(base, local)
        aio.debug "Computing base:remote diffs"
        @base_remote_diffs = Archimate.diff(base, remote)
        aio.debug "Identify merged duplicates"
        find_merged_duplicates
        aio.debug "Finding Conflicts"
        conflicts.find(@base_local_diffs, @base_remote_diffs)
        aio.debug "Applying Diffs"
        @merged = apply_diffs(base_remote_diffs + base_local_diffs, @merged)
      end

      def find_merged_duplicates
        [@base_local_diffs, @base_remote_diffs].map do |diffs|
          deleted_element_diffs = diffs.select(&:delete?).select(&:element?)
          deleted_element_diffs.each_with_object({}) do |diff, a|
            element = diff.from_model.lookup(diff.element_id)
            found = diff.from_model.elements.select do |id, el|
              el != element && el.type == element.type && el.name == element.name
            end
            unless found.empty?
              a[diff] = found
              puts "\nFound potential de-duplication:"
              puts "\t#{diff}"
              puts "Might be replaced with:\n\t#{found.values.map(&:to_s).join("\n\t")}\n\n"
            end
          end
        end
      end

      # TODO: All of the apply diff stuff belongs elsewhere?
      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        aio.debug "Applying #{diffs.size} diffs"
        remaining_diffs = conflicts.filter_diffs(diffs)
        aio.debug "Filtering out #{conflicts.size} conflicts - applying #{remaining_diffs.size}"
        remaining_diffs.inject(model) do |m, diff|
          apply_diff(m, diff.with(path: diff.path.split("/")[1..-1].join("/")))
        end
      end

      # TODO: This is in need of refactoring
      def apply_diff(node, diff)
        path = diff.path.split("/")
        # TODO: this is a travesty! Fix me!
        path.delete("Bounds")
        path.delete("Style")
        path.delete("Float")
        path.delete("Fixnum")
        attr_name = path.shift.to_sym
        inst_var_sym = "@#{attr_name}".to_sym
        attr_name = attr_name.to_sym

        if path.empty?
          # Intention here is to handle simple types like string, integer
          node.instance_variable_set(inst_var_sym, diff.to)
          node
        else
          child_collection = node.send(attr_name)
          id = path.shift
          # Note: if the path is empty at this point, there's no more need to drill down
          if path.empty?
            if diff.is_a?(Delete)
              node.send(attr_name).delete(diff.from)
              node
            elsif child_collection.is_a? Dry::Struct
              node.instance_variable_set("@#{id}".to_sym, diff.to)
              node
            else
              apply_child_changes(node, attr_name, id, diff.to)
            end
          else
            id = id.to_i if child_collection.is_a? Array
            child = child_collection[id]
            apply_child_changes(node, attr_name, id, apply_diff(child, diff.with(path: path.join("/"))))
          end
        end
      end

      # TODO: this is a little hokey. I'd like to basically call a diff method based on the
      # type of the child collection here.
      def apply_child_changes(node, attr_name, id, child_value)
        child_collection = node.send(attr_name)
        case child_collection
        when Hash
          node.send(attr_name)[id] = child_value
        when Array
          node.send(attr_name)[id.to_i] = child_value
        else
          raise "Type Error #{child_collection.class} unexpected for collection type, node class=#{node.class}, attr_name=#{attr_name}, id=#{id}, child_value=#{child_value.inspect}"
        end
        node
      end
    end
  end
end
