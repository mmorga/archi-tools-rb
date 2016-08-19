$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

TEST_EXAMPLES_FOLDER = File.join(File.dirname(__FILE__), "examples")

if ENV['TEST_ENV'] != 'guard'
  require 'simplecov'
  SimpleCov.start do
    add_filter "/test/"
  end
  puts "required simplecov"
end

require 'archimate'
require 'nokogiri'

require 'minitest/autorun'
require 'minitest/color'
