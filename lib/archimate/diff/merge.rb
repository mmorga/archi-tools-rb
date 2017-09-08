# frozen_string_literal: true
require "parallel"

module Archimate
  module Diff
    class Merge
      include Archimate::Logging

      def three_way(base, local, remote)
        debug { "Computing base:local & base:remote diffs" }
        base_local_diffs, base_remote_diffs = Parallel.map([[base, local], [base, remote]],
          in_processes: 2) do |base_model, other_model|
          base_model.diff(other_model)
        end

        # base_local_diffs, base_remote_diffs = [[base, local], [base, remote]].map do |base_model, other_model|
        #   base_model.diff(other_model)
        # end

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
    end
  end
end
