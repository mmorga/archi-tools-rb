# frozen_string_literal: true

module Archimate
  # This is a helper module to make logging calls a little less clunky
  module Logging
    def update(sym, val)
      @logger = val if sym == :logger
    end

    def logger
      unless defined?(@logger)
        config = Archimate::Config.instance
        config.add_observer(self)
        @logger = config.logger
      end
      @logger
    end

    def debug(progname = nil, &block)
      logger.debug(progname, &block)
    end

    def error(progname = nil, &block)
      logger.error(progname, &block)
    end

    def fatal(progname = nil, &block)
      logger.fatal(progname, &block)
    end

    def info(progname = nil, &block)
      logger.info(progname, &block)
    end

    def self.logger
      Archimate::Config.instance.logger
    end

    def self.debug(progname = nil, &block)
      logger.debug(progname, &block)
    end

    def self.error(progname = nil, &block)
      logger.error(progname, &block)
    end

    def self.fatal(progname = nil, &block)
      logger.fatal(progname, &block)
    end

    def self.info(progname = nil, &block)
      logger.info(progname, &block)
    end
  end
end
