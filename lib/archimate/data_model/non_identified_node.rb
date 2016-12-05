# frozen_string_literal: true
module Archimate
  module DataModel
    class NonIdentifiedNode < ArchimateNode
      def id
        object_id.to_s
      end
    end
  end
end
