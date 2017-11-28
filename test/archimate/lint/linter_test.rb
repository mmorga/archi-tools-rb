# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Lint
    class LinterTest < Minitest::Test
      def test_entity_naming_rules
        model = build_model(
          elements: [
            build_element(name: ""),
            build_element(name: nil),
            build_element(name: "a"),
            build_element(name: "a (copy)")
          ]
        )

        subject = Linter.new(model)
        errors = subject.entity_naming_rules
        assert_match(/name is empty/, errors[0])
        assert_match(/name is empty/, errors[1])
        assert_match(/name a is too short/, errors[2])
        assert_match(/name a \(copy\) contains '\(copy\)'/, errors[3])
      end
    end
  end
end
