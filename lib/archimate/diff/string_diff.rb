# frozen_string_literal: true
module Archimate
  module Diff
    class StringDiff
      def diffs(ctx)
        return [] if ctx.model1 == ctx.model2
        return [Difference.insert(ctx.path_str, ctx.model2)] if ctx.model1.nil?
        return [Difference.delete(ctx.path_str, ctx.model1)] if ctx.model2.nil?
        [Difference.change(ctx.path_str, ctx.model1, ctx.model2)]
      end
    end
  end
end
