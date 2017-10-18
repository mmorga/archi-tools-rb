# frozen_string_literal: true
require 'test_helper'
require "test_examples"

module Archimate
  module Cli
    class SvgerTest < Minitest::Test
      def test_export_svgs
        model = Archimate.parse(archisurance_source)
        Dir.mktmpdir do |tmpdir|
          subject = Svger.new(model.diagrams, tmpdir)
          subject.export_svgs
        end
      end
    end
  end
end
