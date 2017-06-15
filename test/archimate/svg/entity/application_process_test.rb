# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class ApplicationProcessTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.nodes.first
        end

        def test_badge
          subject = ApplicationProcess.new(@child, build_bounds)
          refute_nil subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
