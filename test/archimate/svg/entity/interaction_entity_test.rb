# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class InteractionEntityTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.children.first
          @subject = InteractionEntity.new(@child, build_bounds)
        end

        def test_badge
          refute_nil @subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
