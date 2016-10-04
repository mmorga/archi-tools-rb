module Archimate
  module DataModel
    module With
      def with(options = {})
        self.class.new(to_h.merge(options))
      end
    end
  end
end
