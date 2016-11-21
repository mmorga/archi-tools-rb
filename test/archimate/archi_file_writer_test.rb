# frozen_string_literal: true
require 'test_helper'

module Archimate
  class ArchiFileWriterTest < Minitest::Test
    attr_accessor :model

    TEXT_SUBSTITUTIONS = [
      ['&#13;', '&#xD;'],
      ['"', '&quot;'],
      ['&gt;', '>']
    ].freeze

    def process_text(doc_str)
      %w(documentation content).each do |tag|
        TEXT_SUBSTITUTIONS.each do |from, to|
          doc_str.gsub!(%r{<#{tag}>([^<]*#{from}[^<]*)</#{tag}>}) do |str|
            str.gsub(from, to)
          end
        end
      end
      doc_str
    end

    def setup
      # @model = ArchiFileReader.read(File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate"))
      tmp = File.join(File.dirname(__FILE__), "..", "..", "tmp")
      @model = ArchiFileReader.read(File.join(tmp, "Rackspace.archimate"))
      @filename = "test-writer.archimate"
    end

    def test_write
      File.open(@filename, "w") do |f|
        ArchiFileWriter.write(@model, f)
      end
      raw_file = File.read(@filename)
      File.open(@filename, "w") do |f|
        f.write(
          process_text(
            raw_file.gsub(
              %r{<(/)?archimate:}, "<\\1"
            ).gsub(
              %r{<(/)?model}, "<\\1archimate:model"
            )
          )
        )
      end
    end

    def test_remove_nil_values
      h = {
        "z" => "something",
        "m" => nil,
        "a" => "this"
      }
      assert_equal %w(z m a), h.keys
      expected_keys = ["z", "a"]

      result = ArchiFileWriter.new(@model).remove_nil_values(h)

      assert_equal expected_keys, result.keys
      assert_equal expected_keys, h.keys
    end
  end
end
