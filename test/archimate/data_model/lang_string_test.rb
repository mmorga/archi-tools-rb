# frozen_string_literal: true

require 'test_helper'

module Archimate
  module DataModel
    class LangStringTest < Minitest::Test
      attr_accessor :subject
      attr_accessor :subject_lang

      def setup
        @subject = LangString.new("hello")
        @subject_lang = LangString.new(
          lang_hash: { "elvish" => "Elrond" },
          default_lang: "elvish",
          default_text: "Elrond"
        )
      end

      def test_constructor
        assert_instance_of LangString, subject
        assert_equal "hello", subject.text
        assert_equal "hello", subject.to_s
        assert_nil subject.lang
      end

      def test_to_s
        assert_match(subject.text, subject.to_s)
      end

      def test_to_hash
        expected = { lang_hash: { nil => "hello" }, default_lang: nil, default_text: "hello" }
        assert_equal expected, @subject.to_h
      end

      def test_with_lang_default
        assert_match("elvish", subject_lang.lang)
      end

      def test_with_lang_by_lang
        assert_match("Elrond", subject_lang.by_lang("elvish"))
      end

      def test_default_text
        assert_equal "hello", @subject.default_text
      end

      def test_empty?
        refute_empty @subject
      end

      def test_strip
        assert_equal "blah", LangString.new("   blah   ").strip
      end

      def test_tr
        assert_equal "h*ll*", @subject.tr('aeiou', '*')
      end

      def test_plus
        assert_equal "hello world", @subject + " world"
      end

      def test_gsub
        assert_equal "heyyo", @subject.tr("l", "y")
      end

      def test_sub
        assert_equal "heylo", @subject.sub("l", "y")
      end

      def test_downcase
        assert_equal "lowcase", LangString.new("LOWCASE").downcase
      end

      def test_split
        assert_equal %w[h e l l o], @subject.split(//)
      end
    end
  end
end
