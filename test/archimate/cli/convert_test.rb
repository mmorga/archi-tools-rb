# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class ConvertTest < Minitest::Test
      def setup
        @subject = Convert.new(AIO.new)
      end

      def test_io_attribute
        assert_kind_of AIO, @subject.instance_variable_get(:@io)
      end

      def test_with_graphml
        result_io = StringIO.new
        expected = <<-END
<?xml version="1.0" encoding="UTF-8"?>
<graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
        END
        @subject.convert(ARCHISURANCE_FILE, result_io, "to" => "graphml")

        assert result_io.string.start_with?(expected)
      end
    end
  end
end
