# frozen_string_literal: true

require 'test_helper'
require 'test_examples'

module Archimate
  class FileFormatTest < Minitest::Test
    def test_read_marshal_format
      model = FileFormat.read(ARCHISURANCE_30_MARSHAL_FILE)
      assert_equal model.id, model_exchange_archisurance_30_model.id
    end
  end
end
