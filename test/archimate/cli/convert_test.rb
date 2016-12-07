# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class ConvertTest < Minitest::Test
      def setup
        @output_io = StringIO.new
        @aio = AIO.new(
          model: ARCHISURANCE_MODEL,
          output_io: @output_io
        )
        @subject = Convert.new(@aio)
      end

      def test_io_attribute
        assert_kind_of AIO, @subject.instance_variable_get(:@io)
      end

      def test_with_graphml
        expected = <<-END
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
        END
        @subject.convert("graphml")

        assert @output_io.string.start_with?(expected)
      end
    end
  end
end
