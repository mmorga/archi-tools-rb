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
      attr_reader :merged
      attr_reader :aio

      def initialize(base, local, remote, aio)
        @merged = base.clone
        @base = base
        @local = local
        @remote = remote
        @conflicts = Conflicts.new(aio)
        @base_local_diffs = []
        @base_remote_diffs = []
        @aio = aio
      end

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
        # aio.debug "Identify merged duplicates"
        # find_merged_duplicates
        aio.debug "Finding Conflicts"
        conflicts.find(@base_local_diffs, @base_remote_diffs)
        aio.debug "Applying Diffs"
        @merged = apply_diffs(base_remote_diffs + base_local_diffs, @merged)
      end

      def find_merged_duplicates
        [@base_local_diffs, @base_remote_diffs].map do |diffs|
          deleted_element_diffs = diffs.select(&:delete?).select(&:element?)
          deleted_element_diffs.each_with_object({}) do |diff, a|
            element = diff.from_model.elements[diff.element_idx]
            found = diff.from_model.elements.select do |el|
              el != element && el.type == element.type && el.name == element.name
            end
            next if found.empty?
            a[diff] = found
            aio.debug "\nFound potential de-duplication:"
            aio.debug "\t#{diff}"
            aio.debug "Might be replaced with:\n\t#{found.map(&:to_s).join("\n\t")}\n\n"
          end
        end
      end

      def filter_path_conflicts(diffs)
        diffs.sort { |a, b| a.path_to_array.size <=> b.path_to_array.size }.each_with_object([]) do |i, e|
          diffs.delete(i)
          path_conflicts = diffs.select { |d| d.path.start_with?(i.path) }
          path_conflicts.each { |d| diffs.delete(d) }
          e << i
        end
      end

      # TODO: All of the apply diff stuff belongs elsewhere?
      # TODO: diffs should be sorted to apply in a way that makes sense, right?
      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        aio.debug "Applying #{diffs.size} diffs"
        remaining_diffs = conflicts.filter_diffs(diffs)
        aio.debug "Filtering out #{conflicts.size} conflicts - applying #{remaining_diffs.size}"
        remaining_diffs = filter_path_conflicts(remaining_diffs)
        remaining_diffs.sort.inject(model) { |a, e| apply_diff(a, e) }.compact
      end

      def apply_diff(model, diff)
        aio.debug("Applying #{diff.path}: #{diff}")
        case diff
        when Delete
          model.delete_at(diff.path)
        when Insert
          model.insert_at(diff.path, diff.inserted)
        when Change
          model.set_at(diff.path, diff.to)
        end
        model
      end
    end
  end
end
