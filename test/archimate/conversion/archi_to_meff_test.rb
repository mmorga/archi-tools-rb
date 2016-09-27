# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Conversion
    class ArchiToMeffTest < Minitest::Test
      def test_start_element
        outfile = Tempfile.new("archi_to_meff_test.xml")
        begin
          archi_to_meff = ArchiToMeff.new(outfile)
          archi_to_meff.start_element("test")
          expected_node = {name: "test", attrs: {}, parent: nil, children: []}
          assert_equal expected_node, archi_to_meff.instance_variable_get(:@cur_node)
          assert_equal [expected_node], archi_to_meff.instance_variable_get(:@cur_path)
        ensure
          outfile.close
          outfile.unlink
        end
      end
    end
  end
end
