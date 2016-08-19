## This class passes an IO (or a fake IO) to the given block based on passing
# either a filename to permit ouput into or nil for a fake IO.
#
module Archimate
  class MaybeIO
    # Creates a MaybeIO object passing it yielding it to the given block
    #
    # @param filename [String, nil] determines the IO yielded to the given block
    #   String: filename to make writable IO for
    #   nil:  - A fake IO
    # @yieldparam [IO] the given block gets an IO (or fake IO)
    #
    # @example Usage
    #   Archimate::MaybeIO.new(myfile) do |io|
    #     io.write("Writing away")
    #   end
    def initialize(filename)
      if filename.nil?
        yield self
      else
        File.open(filename, "w") do |io|
          yield io
        end
      end
    end

    # Implementation of the NilIO write method - effectively passes the input
    # String to /dev/null
    #
    # @param _str [String] - unused, no effect
    def write(_str)
    end
  end
end
