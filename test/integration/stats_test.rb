# frozen_string_literal: true

require 'test_helper'

module Archimate
  class StatsTest < Minitest::Test
    def test_stats_archi_format
      out, err = capture_io do
        Cli::Archi.start %w[stats test/examples/archisurance.archimate]
      end
      assert_empty err
      result = Color.uncolor(out)
      assert_match(/Business *68\b/, result)
      assert_match(/Application *22\b/, result)
      assert_match(/Technology *21\b/, result)
      assert_match(/Motivation *9\b/, result)
      assert_match(/Total Elements *120\b/, result)
      assert_match(/Relationships *178\b/, result)
      assert_match(/Diagrams *17\b/, result)
    end

    def test_stats_archimate_model_exchange_format
      out, err = capture_io do
        Cli::Archi.start ["stats", "test/examples/ArchiSurance V3.xml"]
      end
      assert_empty err
      result = Color.uncolor(out)
      assert_match(/Business *67\b/, result)
      assert_match(/Application *25\b/, result)
      assert_match(/Technology *18\b/, result)
      assert_match(/Motivation *9\b/, result)
      assert_match(/Total Elements *119\b/, result)
      assert_match(/Relationships *179\b/, result)
      assert_match(/Diagrams *17\b/, result)
    end
  end
end
