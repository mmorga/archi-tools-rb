# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

TEST_EXAMPLES_FOLDER = File.join(File.dirname(__FILE__), "examples")
TEST_OUTPUT_FOLDER = File.join(File.dirname(__FILE__), "..", "tmp")

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
require 'factory_girl'
require 'faker'
require 'pp'
require 'archimate'

def random_element_type
  random ||= Random.new(Random.new_seed)
  elements ||= %w(BusinessActor BusinessCollaboration BusinessEvent BusinessFunction
                  BusinessInteraction BusinessInterface BusinessObject BusinessProcess
                  BusinessRole BusinessService Contract Location Meaning Value Product
                  Representation ApplicationCollaboration ApplicationComponent
                  ApplicationFunction ApplicationInteraction ApplicationInterface
                  ApplicationService DataObject Artifact CommunicationPath Device
                  InfrastructureFunction InfrastructureInterface InfrastructureService
                  Network Node SystemSoftware Assessment Constraint Driver Goal Principle
                  Requirement Stakeholder Deliverable Gap Plateau WorkPackage AndJunction
                  Junction OrJunction)
  elements[random.rand(elements.size)]
end

class Minitest::Test
  include FactoryGirl::Syntax::Methods
end

FactoryGirl.find_definitions
