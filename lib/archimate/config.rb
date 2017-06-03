# frozen_string_literal: true

require "logger"
require "singleton"

module Archimate
  class Config
    include Singleton

    attr_accessor :interactive
    attr_accessor :logger

    def initialize
      @interactive = true
      @logger ||= Logger.new(STDERR)
    end
  end
end
