# frozen_string_literal: true
# This class passes an IO (or a fake IO) to the given block based on passing
# a set of options for output with either a filename or an io object
#
require "highline"

module Archimate
  class OutputIO
    attr_reader :output_io, :force
    # opens an output file, passing the io to the given block
    # if the file exists, and the overwrite answer is yes, then the file
    # is overwritten and the block is called
    # if the overwrite answer is no, then the method returns without calling
    # the block
    # $stdout is used if output is nil or empty
    #
    # @param options [Hash, nil] determines the IO yielded to the given block
    #   Hash: Options hash containing values for "output" String (filename) and
    #         boolean "force" to overwrite "output" without confirmation.
    #   nil: The default STDOUT IO.
    # @param default_io [IO, String] default IO to use if not included in options
    # @yieldparam [IO] the given block gets an IO (default $stdout)
    #
    # @example Usage
    #   Archimate::OutputIO.new("output" => myfile) do |io|
    #     io.write("Writing away")
    #   end

    def initialize(options = {}, default_io = $stdout)
      output = options.fetch("output", nil)
      output = default_io if output.nil? || output.empty?

      if output.is_a?(String)
        if !options.key?("force") && File.exist?(output)
          return unless HighLine.new.agree("File #{output} exists. Overwrite?")
        end
        File.open(output, "w") do |io|
          yield io
        end
      else
        yield output
      end
    end
  end
end
