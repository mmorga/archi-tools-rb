# frozen_string_literal: true
require "ruby-progressbar"
require "highline"

HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
  cs[:headline]                       = [:bold, :yellow, :on_black]
  cs[:horizontal_line]                = [:bold, :white]
  cs[:even_row]                       = [:green]
  cs[:odd_row]                        = [:magenta]
  cs[:error]                          = [:bold, :red]
  cs[:warning]                        = [:bold, :yellow]
  cs[:debug]                          = [:gray]
  cs[:insert]                         = [:bold, :green]
  cs[:change]                         = [:bold, :yellow]
  cs[:delete]                         = [:bold, :red]
  cs[:Business]                       = [:black, :on_yellow]
  cs[:Application]                    = [:black, :on_light_blue]
  cs[:Technology]                     = [:black, :on_light_green]
  cs[:Motivation]                     = [:white, :on_blue]
  cs[:"Implementation and Migration"] = [:white, :on_green]
  cs[:Connectors]                     = [:white, :on_black]
  cs[:unknown_layer]                  = [:black, :on_red]
  cs[:Model]                          = [:cyan]
  cs[:SourceConnection]               = [:blue]
  cs[:Folder]                         = [:cyan]
  cs[:Relationship]                   = [:black]
  cs[:Diagram]                        = [:cyan]
  cs[:path]                           = [:light_blue]
end

module Archimate
  class FakeProgressBar
    def increment
    end
  end

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
    attr_reader :interactive

    def initialize(options = {})
      @in_io = options.fetch(:in_io, $stdin)
      @out = options.fetch(:output, $stdout)
      @err = options.fetch(:err, $stderr)
      @uin = options.fetch(:uin, $stdin)
      @uout = options.fetch(:uout, $stdout) # $stderr)
      @interactive = options.fetch(:interactive, true)
      @verbose = options.fetch(:verbose, false)
      @force = options.fetch(:force, false)
      @output_dir = options.fetch(:output_dir, Dir.pwd)
      @model = options.fetch(:model, nil)
      @hl = HighLine.new(@uin, @uout)
    end

    # def with_output(&_block)
    #   if out.is_a?(String)
    #     if !force && File.exist?(out)
    #       return unless HighLine.new.agree("File #{out} exists. Overwrite?")
    #     end
    #     File.open(out, "w") do |io|
    #       yield io
    #     end
    #   else
    #     yield out
    #   end
    # end

    # def model
    #   @model ||= Archimate.read(in_io)
    # end

    def create_progressbar(options = {})
      interactive ? ProgressBar.new(options) : FakeProgressBar.new
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

    def puts(msg)
      @hl.say(msg)
    end

    def resolve_conflict(conflict)
      return [] unless interactive
      choice = @hl.choose do |menu|
        menu.prompt = conflict

        menu.choice(:local, text: conflict.base_local_diffs.map(&:to_s).join("\n\t\t"))
        menu.choice(:remote, text: conflict.base_remote_diffs.map(&:to_s).join("\n\t\t"))
        menu.choice(:neither, help: "Don't choose either set of diffs")
        menu.choice(:edit, help: "Edit the diffs (coming soon)")
        menu.choice(:quit, help: "I'm in over my head. Just stop!")
        menu.select_by = :index_or_name
      end
      puts choice.inspect
      case choice
      when :local
        conflict.base_local_diffs
      when :remote
        conflict.base_remote_diffs
      else
        error "Unexpected choice #{choice.inspect}."
      end
    end

    def self.layer_color(layer, str)
      sym = HighLine.color_scheme.include?(layer.to_sym) ? layer.to_sym : :unknown_layer
      HighLine.color(str, sym)
    end

    def self.data_model(str)
      layer_color(str, str)
    end
  end
end
