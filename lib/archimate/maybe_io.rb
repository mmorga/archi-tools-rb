## This class passes an IO (or a fake IO) to the given block based on passing
# either a filename to permit ouput into or nil for a fake IO.
#
# = Usage
#
#      Archimate::MaybeIO.new(myfile) do |io|
#        io.write("Writing away")
#      end
#
module Archimate
  class MaybeIO
    def initialize(filename)
      if filename.nil?
        yield self
      else
        File.open(filename, "w") do |io|
          yield io
        end
      end
    end

    def write(_str)
    end
  end
end
