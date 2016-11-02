# frozen_string_literal: true
require 'test_helper'

module Archimate
  module DataModel
    class SourceConnectionTest < Minitest::Test
      attr_reader :src_conn

      def setup
        @src_conn = build_source_connection(
          id: "abc123",
          type: "three",
          source: "source",
          target: "target",
          relationship: "complicated"
        )
      end

      def test_create
        assert_equal "abc123", src_conn.id
        assert_equal "three", src_conn.type
        refute_respond_to src_conn, :type=
      end
    end
  end
end
