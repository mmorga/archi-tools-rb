# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  class FileFormatTest < Minitest::Test
    def test_read_marshal_format
      Dir.mktmpdir do |dir|
        filename = File.join(dir, "model-exchange-archisurance-30.marshal")
        File.open(filename, "wb") do |io|
          io.write(Marshal.dump(model_exchange_archisurance_30_model))
        end
        model = FileFormat.read(filename)
        assert_equal model.id, model_exchange_archisurance_30_model.id
      end
    end
  end
end
