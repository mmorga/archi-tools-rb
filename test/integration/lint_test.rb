# frozen_string_literal: true

require 'test_helper'

module Archimate
  class LintTest < Minitest::Test
    def test_lint_archi_format
      out, err = capture_io do
        Cli::Archi.start %w[lint test/examples/archisurance.archimate]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "Total Issues: 72", result
      duplicate = <<~DUPLICATE
        Duplicate Items:
                BusinessInterface<1540>[phone]
                BusinessInterface<1536>[phone]
      DUPLICATE
      assert_match duplicate, result
      assert_match "Unused Relationship: Realization<1436>[] BusinessProcess<580>[Valuate] -> BusinessService<1214>[Customer Information Service]", result
      assert_match "Access<712>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File]", result
      assert_match "Visual Nesting: SystemSoftware<1022>[CICS] should not nest in Node<986>[Mainframe] without valid relationship", result
    end

    def test_lint_archimate_exchange_format
      out, err = capture_io do
        Cli::Archi.start ["lint", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "Unused Relationship: Flow<id-4937-124-4932>[] BusinessFunction<id-4937>[Financial Handling] -> BusinessFunction<id-4932>[Asset Management]
", result
      assert_match "Empty View: Diagram<id-5661>[Archimate View]", result
      assert_match "Visual Nesting: SystemSoftware<id-4999>[DBMS] should not nest in Node<id-5003>[Mainframe] without valid relationship", result
      assert_match "Total Issues: 87", result
    end
  end
end
