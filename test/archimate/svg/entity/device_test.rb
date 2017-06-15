# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Svg
    module Entity
      class DeviceTest < Minitest::Test
        def setup
          @model = build_model(
            diagrams: [
              build_diagram
            ]
          )
          @child = @model.diagrams.first.nodes.first
          @subject = Device.new(@child, build_bounds)
        end

        def test_badge
          assert_nil @subject.instance_variable_get(:@badge)
        end
      end
    end
  end
end
