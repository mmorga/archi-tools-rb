# frozen_string_literal: true
require "highline"

module Archimate
  module ErrorHelper
    def error(msg)
      HighLine.new.say("#{HighLine.color('Error:', :error)} #{msg}")
    end

    def warning(msg)
      HighLine.new.say("#{HighLine.color('Warning:', :warning)} #{msg}")
    end

    def info(msg)
      HighLine.new.say(msg)
    end
  end
end
