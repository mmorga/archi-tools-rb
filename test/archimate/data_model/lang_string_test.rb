# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class LangStringTest < Minitest::Test
      attr_accessor :subject
      def setup
        @subject = LangString.new("hello")
      end

      def test_constructor
      	assert_instance_of LangString, subject
      	assert_equal "hello", subject.text
      	assert_equal "hello", subject.to_s
      	assert_nil subject.lang
      end

      def test_to_s
        assert_match(@subject.text, @subject.to_s)
      end

      def test_with_lang
        subject_lang = LangString.new(text: "Elrond", lang: "elvish")
        assert_match("elvish", subject_lang.lang)
      end
    end
  end
end
