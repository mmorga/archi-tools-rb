# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class ApplicationServiceTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.children.first
        end

        def test_badge
          subject = ApplicationService.new(@child, build_bounds)
          assert_nil subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
