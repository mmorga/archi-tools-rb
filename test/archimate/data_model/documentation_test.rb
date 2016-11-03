# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DocumentationTest < Minitest::Test
      def setup
        @subject = build_documentation
      end

      def test_comparison_attributes
        assert_equal [:@lang, :@text], @subject.comparison_attributes
      end

      def test_to_s
        assert_match(/Documentation/, @subject.to_s)
        assert_match(@subject.text, @subject.to_s)
      end

      def test_to_s_with_lang
        subject = build_documentation(lang: "elvish")
        assert_match("elvish", subject.to_s)
      end
    end
  end
end
