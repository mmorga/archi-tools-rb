# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Model
    class ChildTest < Minitest::Test
      def test_new
        c = Child.new("123")
        assert_equal "123", c.id
        [:id, :type, :text_alignment, :fill_color, :model, :name,
         :target_connections, :archimate_element, :font, :line_color,
         :font_color, :bounds, :children, :source_connection].each { |sym| assert c.respond_to?(sym) }
      end
    end
  end
end
