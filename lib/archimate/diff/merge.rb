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
        @base = IceNine.deep_freeze!(base)
        @local = IceNine.deep_freeze!(local)
        @remote = IceNine.deep_freeze!(remote)
        @conflicts = Conflicts.new
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
        aio.debug "#{DateTime.now}: Computing base:local diffs"
        @base_local_diffs = Archimate.diff(base, local)
        aio.debug "#{DateTime.now}: Computing base:remote diffs"
        @base_remote_diffs = Archimate.diff(base, remote)
        aio.debug "#{DateTime.now}: Finding Conflicts"
        @all_diffs = base_local_diffs + base_remote_diffs
        find_conflicts
        aio.debug "#{DateTime.now}: Applying Diffs"
        @merged = apply_diffs(base_remote_diffs + base_local_diffs, @merged)
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

      def find_conflicts
        aio.debug "#{DateTime.now}: find_diff_path_conflicts"
        conflicts << find_diff_path_conflicts
        aio.debug "#{DateTime.now}: find_diagram_delete_update_conflicts"
        conflicts << find_diagram_delete_update_conflicts
        aio.debug "#{DateTime.now}: find_deleted_elements_referenced_in_diagrams"
        conflicts << find_deleted_elements_referenced_in_diagrams
        aio.debug "#{DateTime.now}: find_deleted_relationships_referenced_in_diagrams"
        conflicts << find_deleted_relationships_referenced_in_diagrams
        aio.debug "#{DateTime.now}: find_deleted_elements_referenced_in_relationships"
        conflicts << find_deleted_elements_referenced_in_relationships
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
              diagram_deleted_diffs(diffs1),
              diagram_updated_diffs(diffs2)
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

      def find_diff_path_conflicts
        @base_local_diffs.each_with_object([]) do |ldiff, cfx|
          conflicting_remote_diffs =
            @base_remote_diffs.select { |rdiff| ldiff.path == rdiff.path && ldiff != rdiff }.select do |rdiff|
              if !(ldiff.array? && rdiff.array?)
                true
              else
                case [ldiff, rdiff].map { |d| d.class.name.split('::').last }.sort
                when %w(Change Change)
                  # TODO: if froms same and tos diff then conflict if froms diff then 2 sep changes else 1 change
                  ldiff.from == rdiff.from && ldiff.to != rdiff.to
                when %w(Change Delete)
                  # TODO: if c.from d.from same then conflict else 1 c and 1 d
                  ldiff.from == rdiff.from
                else
                  false
                end
              end
            end.uniq

          cfx << Conflict.new(
            ldiff,
            conflicting_remote_diffs,
            "Conflicting changes"
          ) unless conflicting_remote_diffs.empty?
        end
      end

      def diagram_deleted_diffs(diffs)
        diffs.select { |i| i.is_a?(Delete) && i.diagram? }
      end

      def diagram_updated_diffs(diffs)
        diffs.select(&:in_diagram?)
      end

      def find_deleted_elements_referenced_in_diagrams
        [base_local_diffs, base_remote_diffs].permutation(2).each_with_object([]) do |(md1, md2), a|
          md2_diagram_diffs = md2.select(&:in_diagram?)
          a.concat(
            md1.select { |d| d.element? && d.is_a?(Delete) }.each_with_object([]) do |md1_diff, conflicts|
              conflicting_md2_diffs = md2_diagram_diffs.select do |md2_diff|
                md2_diff.model.diagrams[md2_diff.diagram_id].element_references.include? md1_diff.element_id
              end
              conflicts << Conflict.new(md1_diff,
                                        conflicting_md2_diffs,
                                        "Elements referenced in deleted diagram") unless conflicting_md2_diffs.empty?
            end
          )
        end
      end

      # There exists a conflict between d1 & d2 if d1 deletes a relationship that is added or part of a change referenced
      # in a d2 diagram.
      #
      # Side one filter: diffs1.delete?.relationship?
      # Side two filter: diffs2.!delete?.source_connection?
      # Check: diff2.source_connection.relationship == diff1.relationship_id
      def find_deleted_relationships_referenced_in_diagrams
        ds1 = all_diffs.select(&:delete?).select(&:relationship?)
        ds2 = all_diffs.reject(&:delete?).select(&:in_diagram?)
        ds1.each_with_object([]) do |d1, a|
          ds2c = ds2.select do |d2|
            d2.model.diagrams[d2.diagram_id].relationships.include? d1.relationship_id
          end
          a << Conflict.new(
            d1,
            ds2c,
            "Relationship referenced in deleted diagram"
          ) unless ds2c.empty?
        end
      end

      # There exists a conflict if a relationship is added (or changed?) on one side that references an
      # element that is deleted on the other side.
      #
      # Side one filter: diffs1.insert?.relationship? map(:source, :target)
      # Side two filter: diffs2.delete?.element? map(:element_id)
      # Check diffs1.source == element_id or diffs1.target == element_id
      def find_deleted_elements_referenced_in_relationships
        ds1 = all_diffs.reject(&:delete?).select(&:relationship?)
        ds2 = all_diffs.select(&:delete?).select(&:element?)
        ds1.each_with_object([]) do |d1, a|
          rel = d1.relationship
          rel_el_ids = [rel.source, rel.target]
          ds2_conflicts = ds2.select { |d2| rel_el_ids.include?(d2.element_id) }
          a << Conflict.new(
            d1,
            ds2_conflicts,
            "Added/updated relationship references in deleted element"
          ) unless ds2_conflicts.empty?
        end
      end
    end
  end
end
