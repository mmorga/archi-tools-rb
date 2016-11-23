# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Conversion
    class NQuadsTest < Minitest::Test
      def test_quads
        model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        subject = NQuads.new(model)

        results = subject.to_nq

        model.elements.map(&:name).each do |e|
          assert_match e, results
        end
      end
    end
  end
end
