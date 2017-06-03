# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class SvgerTest < Minitest::Test
      def test_export_svgs
        model = Archimate.parse(ARCHISURANCE_SOURCE)
        Dir.mktmpdir do |tmpdir|
          subject = Svger.new(model.diagrams, tmpdir)
          subject.export_svgs
        end
      end
    end
  end
end
