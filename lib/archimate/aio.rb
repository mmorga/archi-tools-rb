# frozen_string_literal: true

require "highline"

module Archimate
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

    def model
      @model ||= Archimate.read(input_io)
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
  end
end
