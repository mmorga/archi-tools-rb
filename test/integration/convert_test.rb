# frozen_string_literal: true

require 'test_helper'

module Archimate
  class ConvertTest < Minitest::Test
    def test_convert_to_unknown_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "batman", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_match(/Expected '--to' to be one of .*; got batman/, err)
      assert_empty result
    end

    def test_convert_to_meff_21_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "meff2.1", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "<model xmlns=\"http://www.opengroup.org/xsd/archimate\" xmlns:dc=\"http://purl.org/dc/elements/1.1/\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.opengroup.org/xsd/archimate http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd http://purl.org/dc/elements/1.1/ http://dublincore.org/schemas/xmls/qdc/2008/02/11/dc.xsd\"", result
    end

    def test_convert_to_meff_30_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "meff3.0", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "<model xmlns=\"http://www.opengroup.org/xsd/archimate/3.0/\"", result
    end

    def test_convert_to_archi_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "archi", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "<archimate:model xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:archimate=\"http://www.archimatetool.com/archimate\"", result
    end

    def test_convert_to_nquads_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "nquads", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "<id-4927> <named> <Client> .", result
      assert_match "<id-4927> <typed> <BusinessActor> .", result
      assert_match "<id-4927> <in_layer> <Business> .", result
      assert_match "<id-4913> <aggregates> <id-4908> .", result
      assert_match "<id-4913-114-4908> <sources> <id-4913> .", result
      assert_match "<id-4913-114-4908> <target> <id-4908> .", result
    end

    def test_convert_to_graphml_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "graphml", "test/examples/ArchiSurance V3.xml"]
      end
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_empty err
      assert_match "graphml xmlns=\"http://graphml.graphdrawing.org/xmlns\"", result
      assert_match "<node id=\"id-4927\" label=\"Client\" labels=\"BusinessActor:Client\">", result
    end

    def test_convert_to_csv_format
      Dir.mktmpdir do |dir|
        _out, err = capture_io do
          Cli::Archi.start ["convert", "-n", "-f", "-d", dir, "-t", "csv", "test/examples/ArchiSurance V3.xml"]
        end
        assert_empty err
        csv_files = Dir.glob(File.join(dir, "*.csv"))
        assert_equal 33, csv_files.size
      end
    end

    def test_convert_to_cypher_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "cypher", "test/examples/ArchiSurance V3.xml"]
      end
      assert_empty err
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_match "CREATE (n:BusinessActor { `layer`: \"Business\", `name`: \"Client\", `nodeId`: \"id-4927\" });", result
      assert_match "MATCH (s { `nodeId`: \"id-4948\" }),(t { `nodeId`: \"id-4942\" }) CREATE (s)-[r:Specialization { `name`: \"\", `relationshipId`: \"id-4948-110-4942\", `weight`: 1 }]->(t);", result
    end

    def test_convert_to_jsonl_format
      out, err = capture_io do
        Cli::Archi.start ["convert", "-n", "-f", "-t", "jsonl", "test/examples/ArchiSurance V3.xml"]
      end
      assert_empty err
      result = Color.uncolor(out).gsub(/ +\n/, "\n")
      assert_match "{\"_key\":\"id-4927\",\"name\":\"Client\",\"layer\":\"Business\",\"type\":\"BusinessActor\",\"properties\":{}}", result
    end
  end
end
