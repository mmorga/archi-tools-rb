# frozen_string_literal: true

require "parallel"

module Archimate
  module Diff
    class Merge
      include Archimate::Logging
      using DataModel::DiffableArray

      def three_way(base, local, remote)
        debug { "Computing base:local & base:remote diffs" }
        base_local_diffs, base_remote_diffs = Parallel.map([[base, local], [base, remote]],
          in_processes: 2) do |base_model, other_model|
          base_model.diff(other_model)
        end

        debug "Finding Conflicts in #{base_local_diffs.size + base_remote_diffs.size} diffs"
        conflicts = Conflicts.new(base_local_diffs, base_remote_diffs)
        resolved_diffs = conflicts.resolve

        [apply_diffs(resolved_diffs, base.clone), conflicts]
      end

      # Applies the set of diffs to the model returning a
      # new model with the diffs applied.
      def apply_diffs(diffs, model)
        debug { "Applying #{diffs.size} diffs" }
        progressbar = ProgressIndicator.new(total: diffs.size, title: "Applying diffs")
        diffs
          .inject(model) do |model_a, diff|
            progressbar.increment
            diff.apply(model_a)
          end
          .rebuild_index
          .organize
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
      #       debug { "\nFound potential de-duplication:" }
      #       debug { "\t#{diff}" }
      #       debug { "Might be replaced with:\n\t#{found.map(&:to_s).join(" }\n\t")}\n\n"
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
