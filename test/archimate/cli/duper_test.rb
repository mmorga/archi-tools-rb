# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  module Cli
    class DuperTest < Minitest::Test
      def setup
        output_io = StringIO.new
        @duper = Duper.new(build_model, output_io)
      end

      def test_new
        refute_nil @duper
      end

      def test_list
        output_io = StringIO.new
        duper = Duper.new(archisurance_model, output_io)
        duper.list
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
        assert_equal expected, Color.uncolor(output_io.string).gsub(/ +\n/, "\n")
      end

      def test_merge
        skip("This currently fails")
        output_io = StringIO.new
        duper = Duper.new(archisurance_model, output_io, true)
        duper.merge
        # flunk(output_io.string)
      end
    end
  end
end
