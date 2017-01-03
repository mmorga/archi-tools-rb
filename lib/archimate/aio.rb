# frozen_string_literal: true
require "ruby-progressbar"
require "highline"

HighLine.color_scheme = HighLine::ColorScheme.new do |cs|
  cs[:headline]                       = [:underline, :bold, :yellow, :on_black]
  cs[:horizontal_line]                = [:bold, :white]
  cs[:even_row]                       = [:green]
  cs[:odd_row]                        = [:magenta]
  cs[:error]                          = [:bold, :red]
  cs[:warning]                        = [:bold, :yellow]
  cs[:debug]                          = [:gray]
  cs[:insert]                         = [:bold, :green]
  cs[:change]                         = [:bold, :yellow]
  cs[:move]                           = [:bold, :yellow]
  cs[:delete]                         = [:bold, :red]
  cs[:Business]                       = [:black, :on_light_yellow]
  cs[:Application]                    = [:black, :on_light_blue]
  cs[:Technology]                     = [:black, :on_light_green]
  cs[:Motivation]                     = [:black, :on_light_magenta]
  cs[:"Implementation and Migration"] = [:black, :on_light_red]
  cs[:Connectors]                     = [:black, :on_light_gray]
  cs[:unknown_layer]                  = [:black, :on_gray]
  cs[:Model]                          = [:cyan]
  cs[:SourceConnection]               = [:blue]
  cs[:Folder]                         = [:cyan]
  cs[:Relationship]                   = [:black, :on_light_gray]
  cs[:Diagram]                        = [:black, :on_cyan]
  cs[:path]                           = [:light_blue]
end

module Archimate
  class FakeProgressBar
    def increment
    end

    def finish
    end
  end

  class AIO
    attr_reader :input_io
    attr_reader :user_input_io
    attr_reader :messages_io
    attr_reader :output_dir
    attr_reader :verbose
    attr_reader :force
    attr_reader :interactive

    def initialize(
      input_io: $stdin,
      output_io: $stdout,
      user_input_io: $stdin,
      messages_io: $stdout,
      interactive: true,
      verbose: false,
      force: false,
      output_dir: Dir.pwd,
      model: nil
    )
      @input_io = input_io
      @output_io = output_io
      @user_input_io = user_input_io
      @messages_io = messages_io
      @interactive = interactive
      @verbose = verbose
      @force = force
      @output_dir = output_dir
      @model = model
      @hl = HighLine.new(@user_input_io, @messages_io)
    end

    # def with_output(&_block)
    #   if output_io.is_a?(String)
    #     if !force && File.exist?(output_io)
    #       return unless HighLine.new.agree("File #{output_io} exists. Overwrite?")
    #     end
    #     File.open(output_io, "w") do |io|
    #       yield io
    #     end
    #   else
    #     yield output_io
    #   end
    # end

    def model
      @model ||= Archimate.read(input_io, self)
    end

    def create_progressbar(total: 100, title: "ArchiMate!")
      interactive ? ProgressBar.create(total: total, title: title, throttle_rate: 0.5) : FakeProgressBar.new
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
      @messages_io.puts msg
    end

    def output_io
      if @output_io.is_a?(String)
        if !force && File.exist?(@output_io)
          # TODO: This needs to be handled with more grace
          return nil unless @hl.agree("File #{@output_io} exists. Overwrite?")
        end
        @output_io = File.open(@output_io, "w")
      end
      @output_io
    end

    # TODO: this implementation has much to be written
    def resolve_conflict(conflict)
      return [] unless interactive
      choice = @hl.choose do |menu|
        menu.prompt = conflict

        menu.choice(:local, text: conflict.base_local_diffs.map(&:to_s).join("\n\t\t"))
        menu.choice(:remote, text: conflict.base_remote_diffs.map(&:to_s).join("\n\t\t"))
        # menu.choice(:neither, help: "Don't choose either set of diffs")
        # menu.choice(:edit, help: "Edit the diffs (coming soon)")
        # menu.choice(:quit, help: "I'm in over my head. Just stop!")
        menu.select_by = :index_or_name
      end
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
