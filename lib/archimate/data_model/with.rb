module Archimate
  module DataModel
    module With
      def with(options = {})
        self.class.new(to_h.merge(options))
      end

      def parent
        parent_id
      end
    end
  end
end
