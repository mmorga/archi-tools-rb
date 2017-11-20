# frozen_string_literal: true

require 'test_helper'

module Archimate
  module Cli
    class CleanupTest < Minitest::Test
      def setup
        Config.instance.interactive = false
        @model = build_model
        @output = StringIO.new
        @removed_items = StringIO.new
        @subject = Cleanup.new(@model, @output, @removed_items)
      end

      def test_new
        assert_kind_of Cleanup, @subject
      end

      # @todo: test something
      def test_clean
        out, err = capture_io do
          @subject.clean
        end
        assert_empty err
        refute_empty out
      end
    end
  end
end
