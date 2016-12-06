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

require 'pry-byebug'
require 'minitest/autorun'
require 'minitest/color'
require 'minitest/profile'
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
    ARCHISURANCE_MODEL = IceNine.deep_freeze(Archimate.parse(ARCHISURANCE_SOURCE))
    ARCHISURANCE_MODEL_EXCHANGE_FILE = File.join(TEST_EXAMPLES_FOLDER, "archisurance.xml").freeze
    ARCHISURANCE_MODEL_EXCHANGE_SOURCE = File.read(ARCHISURANCE_MODEL_EXCHANGE_FILE).freeze
    MODEL_EXCHANGE_ARCHISURANCE_MODEL = IceNine.deep_freeze(
      Archimate::FileFormats::ModelExchangeFileReader.parse(
        ARCHISURANCE_MODEL_EXCHANGE_SOURCE
      )
    )
  end
end
