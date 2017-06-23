# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class DocumentationTest < Minitest::Test
      def setup
        @subject = build_documentation
      end

      def test_to_s
        assert_match(@subject.text, @subject.to_s)
      end

      def test_to_s_with_lang
        subject = build_documentation(lang: "elvish")
        assert_match("elvish", subject.lang)
      end
    end
  end
end
