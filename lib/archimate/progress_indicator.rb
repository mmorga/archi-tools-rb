# frozen_string_literal: true

require "ruby-progressbar"

module Archimate
  class ProgressIndicator
    class FakeProgressBar
      def increment; end

      def finish; end
    end

    def initialize(total: 100, title: "ArchiMate!")
      @progress = if Config.instance.interactive
                    ProgressBar.create(total: total, title: title, throttle_rate: 0.5)
                  else
                    FakeProgressBar.new
                  end
    end

    def increment
      @progress.increment
    end

    def finish
      @progress.finish
    end
  end
end
