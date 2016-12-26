# frozen_string_literal: true

module Archimate
  module Diff
    class Merge
      using DataModel::DiffableArray

      attr_reader :aio

      def initialize(aio)
        @aio = aio
      end

      def three_way(base, local, remote)
        aio.debug "Computing base:local diffs"
        base_local_diffs = base.diff(local)

        aio.debug "Computing base:remote diffs"
        base_remote_diffs = base.diff(remote)

        aio.debug "Finding Conflicts in #{base_local_diffs.size + base_remote_diffs.size} diffs"
        conflicts = Conflicts.new(base_local_diffs, base_remote_diffs, aio)

        [apply_diffs(conflicts.resolve, base.clone), conflicts]
      end

      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        aio.debug "Applying #{diffs.size} diffs"
        progressbar = @aio.create_progressbar(total: diffs.size, title: "Applying diffs")
        diffs.inject(model) do |model_a, diff|
          progressbar.increment
          diff.apply(model_a)
        end.compact!.organize
      ensure
        progressbar&.finish
      end

      # # TODO: not currently used
      # def find_merged_duplicates
      #   [@base_local_diffs, @base_remote_diffs].map do |diffs|
      #     deleted_element_diffs = diffs.select(&:delete?).select(&:element?)
      #     deleted_element_diffs.each_with_object({}) do |diff, a|
      #       element = diff.from_model.elements[diff.element_idx]
      #       found = diff.from_model.elements.select do |el|
      #         el != element && el.type == element.type && el.name == element.name
      #       end
      #       next if found.empty?
      #       a[diff] = found
      #       aio.debug "\nFound potential de-duplication:"
      #       aio.debug "\t#{diff}"
      #       aio.debug "Might be replaced with:\n\t#{found.map(&:to_s).join("\n\t")}\n\n"
      #     end
      #   end
      # end

      # # TODO: not currently used
      # def filter_path_conflicts(diffs)
      #   diffs.sort { |a, b| a.path_to_array.size <=> b.path_to_array.size }.each_with_object([]) do |i, e|
      #     diffs.delete(i)
      #     path_conflicts = diffs.select { |d| d.path.start_with?(i.path) }
      #     path_conflicts.each { |d| diffs.delete(d) }
      #     e << i
      #   end
      # end
    end
  end
end
