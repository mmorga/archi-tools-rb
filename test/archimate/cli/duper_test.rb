# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class DuperTest < Minitest::Test
      def setup
        input_doc = Nokogiri::XML::Document.new
        output_io = StringIO.new
        aio = AIO.new(output_io: output_io, model: input_doc)
        @duper = Duper.new(aio)
      end

      def test_new
        refute_nil @duper
      end

      def test_simplify
        assert_nil(@duper.simplify(nil))
        assert_equal(@duper.simplify("hello"), "hello")
        assert_equal(@duper.simplify("HellO"), "hello")
        assert_equal(@duper.simplify(" \tHello World\n"), "helloworld")
        assert_equal(@duper.simplify("&Jello-World;yeah!right?"), "jelloworldyeahright")
      end
    end
  end
end
