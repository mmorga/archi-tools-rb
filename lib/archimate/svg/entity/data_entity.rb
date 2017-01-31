# frozen_string_literal: true
module Archimate
  module Svg
    module Entity
      class DataEntity < BaseEntity
        include Data

        def initialize(child, bounds_offset)
          super
        end

        def entity_shape(xml, bounds)
          data_path(xml, bounds)
        end
      end
    end
  end
end
