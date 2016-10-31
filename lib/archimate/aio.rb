# frozen_string_literal: true
require "ruby-progressbar"
require "highline"

HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
  cs[:headline]        = [:bold, :yellow, :on_black]
  cs[:horizontal_line] = [:bold, :white]
  cs[:even_row]        = [:green]
  cs[:odd_row]         = [:magenta]
  cs[:error]           = [:bold, :red]
  cs[:warning]         = [:bold, :yellow]
  cs[:debug]           = [:gray]
end

module Archimate
  class AIO
    attr_reader :in
    attr_reader :uin
    attr_reader :uout
    attr_reader :out
    attr_reader :err
    attr_reader :verbose
    attr_reader :force
    attr_reader :progressbar

    def initialize(options = {})
      opts = {
        in: $stdin,
        out: $stdout,
        err: $stderr,
        uin: $stdin,
        uout: $stderr,
        verbose: false,
        force: false
      }.merge(options)
      @in = opts[:in]
      @out = opts[:out]
      @err = opts[:err]
      @uin = opts[:uin]
      @uout = opts[:uout]
      @verbose = opts[:verbose]
      @force = opts[:force]
      @hl = HighLine.new(@uin, @uout)
      @progressbar = nil
    end

    def create_progressbar(options = {})
      return unless verbose
      @progressbar = ProgressBar.create(options)
    end

    def increment_progressbar
      progressbar.increment if progressbar
    end

    def error(msg)
      @hl.say("#{@hl.color('Error:', :error)} #{msg}")
    end

    def warning(msg)
      @hl.say("#{@hl.color('Warning:', :warning)} #{msg}")
    end

    def info(msg)
      @hl.say(msg)
    end

    def debug(msg)
      @hl.say("#{@hl.color('Debug:', :debug)} #{msg}") if @verbose
    end
  end
end
