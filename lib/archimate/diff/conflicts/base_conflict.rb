# frozen_string_literal: true
module Archimate
  module Diff
    class Conflicts
      # BaseConflict
      # @abstract
      class BaseConflict
        def initialize(base_local_diffs, base_remote_diffs)
          @base_local_diffs = base_local_diffs
          @base_remote_diffs = base_remote_diffs
          @associative = false
          @diff_iterations = nil
        end

        def filter1
          ->(_diff) { true }
        end

        def filter2
          ->(_diff) { true }
        end

        def conflicts
          progressbar = ProgressIndicator.new(total: diff_iterations.size, title: "Analyzing Conflicts")
          diff_iterations.each_with_object([]) do |(md1, md2), conflicts|
            progressbar.increment
            conflicts.concat(
              md1.map { |diff1| [diff1, md2.select(&method(:diff_conflicts).curry[diff1])] }
                .reject { |_diff1, diff2| diff2.empty? }
                .map { |diff1, diff2_ary| Conflict.new(diff1, diff2_ary, describe) }
            )
          end
        ensure
          progressbar.finish
        end

        def diff_combinations
          combos = [@base_local_diffs, @base_remote_diffs]
          @associative ? [combos] : combos.permutation(2)
        end

        # By default our conflict tests are not associative to we need to run
        # [local, remote] and [remote, local] through the tests.
        def diff_iterations
          @diff_iterations ||=
            diff_combinations.map do |local_diffs, remote_diffs|
              [local_diffs.select(&filter1), remote_diffs.select(&filter2)]
            end
        end
      end
    end
  end
end
