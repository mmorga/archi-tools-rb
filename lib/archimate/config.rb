# frozen_string_literal: true

require "logger"
require "singleton"
require "observer"

module Archimate
  # This is the singleton class that contains application configuration.
  class Config
    include Singleton
    include Observable

    attr_reader :interactive
    attr_reader :logger

    def initialize
      @interactive = true
      @logger ||= Logger.new(STDERR, progname: "archimate")
    end

    def interactive=(interactive)
      return @interactive unless @interactive != interactive
      @interactive = interactive
      changed
      notify_observers(:interactive, @interactive)
    end

    def logger=(logger)
      return @logger unless @logger != logger
      @logger = logger
      changed
      notify_observers(:logger, @logger)
    end
  end
end
