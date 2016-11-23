# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

TEST_EXAMPLES_FOLDER = File.join(File.dirname(__FILE__), "examples")

if ENV['TEST_ENV'] != 'guard'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
    coverage_dir "tmp/coverage"
  end
  puts "required simplecov"
end

require 'minitest/autorun'
require 'minitest/color'
require 'faker'
require 'pp'
require 'archimate'
require_relative 'examples/factories'

Minitest::Test.make_my_diffs_pretty!

module Minitest
  class Test
    include Archimate::Examples::Factories

    ARCHISURANCE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.archimate").freeze
    ARCHISURANCE_SOURCE = File.read(ARCHISURANCE_FILE).freeze
  end
end
