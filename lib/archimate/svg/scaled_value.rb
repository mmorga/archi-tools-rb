# frozen_string_literal: true
module Archimate
  module Svg
    class ScaledValue
      def initialize(val_max, scaled_max)
        @vmax = val_max.to_f
        @smax = scaled_max
      end

      def scale(v)
        v / @vmax * @smax
      end
      end
  end
end
