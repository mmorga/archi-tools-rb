module Archidiff
  class Diff
    def self.diff(local, remote)
      my_diff = Diff.new
      my_diff.diff(local, remote)
    end

    def diff(_local, _remote)
      []
    end
  end
end
