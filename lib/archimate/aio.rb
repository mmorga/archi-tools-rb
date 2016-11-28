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
  cs[:insert]          = [:bold, :green]
  cs[:change]          = [:bold, :yellow]
  cs[:delete]          = [:bold, :red]
end

module Archimate
  class AIO
    attr_reader :in_io
    attr_reader :uin
    attr_reader :uout
    attr_reader :out
    attr_reader :err
    attr_reader :verbose
    attr_reader :force
    attr_reader :progressbar
    attr_reader :output_dir

    def initialize(options = {})
      @in_io = options.fetch(:in_io, $stdin)
      @out = options.fetch(:output, $stdout)
      @err = options.fetch(:err, $stderr)
      @uin = options.fetch(:uin, $stdin)
      @uout = options.fetch(:uout, $stderr)
      @verbose = options.fetch(:verbose, false)
      @force = options.fetch(:force, false)
      @output_dir = options.fetch(:output_dir, Dir.pwd)
      @model = options.fetch(:model, nil)
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
      @hl.say("#{@hl.color('Debug:', :debug)} #{DateTime.now} #{msg}") if @verbose
    end

    def self.layer_color(layer, str)
      case layer
      when "Business"
        str.black.on_yellow
      when "Application"
        str.black.on_light_blue
      when "Technology"
        str.black.on_light_green
      when "Motivation"
        str.white.on_blue
      when "Implementation and Migration"
        str.white.on_green
      when "Connectors"
        str.white.on_black
      else
        str.black.on_red
      end
    end
  end
end
