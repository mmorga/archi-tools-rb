# frozen_string_literal: true

require 'test_helper'

module Archimate
  class DupesTest < Minitest::Test
    def test_dupes_archi_format
      out, err = capture_io do
        Cli::Archi.start %w[dupes test/examples/archisurance.archimate]
      end
      expected = <<~EXPECTED
        BusinessInterface has potential duplicates:
        \tBusinessInterface<1540>[phone],
        \tBusinessInterface<1536>[phone]
        Device has potential duplicates:
        \tDevice<1053>[Unix Server],
        \tDevice<1059>[Unix Server]
        Network has potential duplicates:
        \tNetwork<1089>[LAN],
        \tNetwork<1101>[LAN]
        Node has potential duplicates:
        \tNode<998>[Firewall],
        \tNode<1004>[Firewall]
        Access has potential duplicates:
        \tAccess<712>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File],
        \tAccess<90702769>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File]
        Total Possible Duplicates: 10
      EXPECTED
      assert_empty err
      assert_equal expected, Color.uncolor(out).gsub(/ +\n/, "\n")
    end

    def test_dupes_archimate_exchange_format
      out, err = capture_io do
        Cli::Archi.start ["dupes", "test/examples/ArchiSurance V3.xml"]
      end
      expected = <<~EXPECTED
        Total Possible Duplicates: 0
      EXPECTED
      assert_empty err
      assert_equal expected, Color.uncolor(out).gsub(/ +\n/, "\n")
    end
  end
end
