# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  module Cli
    class ConvertTest < Minitest::Test
      def setup
        @output_io = StringIO.new
        @subject = Convert.new(archisurance_model)
      end

      def test_with_graphml
        expected = <<~END
          <?xml version="1.0" encoding="UTF-8"?>
          <graphml xmlns="http://graphml.graphdrawing.org/xmlns" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
        END
        @subject.convert("graphml", @output_io, nil)

        assert @output_io.string.start_with?(expected)
      end
    end
  end
end
