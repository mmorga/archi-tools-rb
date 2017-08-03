# frozen_string_literal: true
module Archimate
  module DataModel
    module With
      # TODO: Consider removing this
      def with(attrs={})
        new(to_hash.merge(attrs).transform_values(&:dup))
      end
    end
  end
end
