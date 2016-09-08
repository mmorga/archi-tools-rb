# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class ModelTest < Minitest::Test
      def test_new
        model = Model.new("123", "my model") do |m|
          m.documentation = %w(documentation1 documentation2)
        end
        assert_equal "123", model.id
        assert_equal "my model", model.name
        assert_equal %w(documentation1 documentation2), model.documentation
      end
    end
  end
end
