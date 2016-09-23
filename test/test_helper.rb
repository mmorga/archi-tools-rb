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
require 'faker'
require 'pp'
require 'archimate'

module Minitest
  class Test
    def build_bounds(options = {})
      Archimate::Model::Bounds.new(
        x: options.fetch(:x, Faker::Number.positive),
        y: options.fetch(:y, Faker::Number.positive),
        width: options.fetch(:width, Faker::Number.positive),
        height: options.fetch(:height, Faker::Number.positive)
      )
    end

    def build_element(options = {})
      Archimate::Model::Element.new(
        id: options.fetch(:id, Faker::Number.hexadecimal(8)),
        label: options.fetch(:label, Faker::Company.buzzword),
        type: options.fetch(:type, random_element_type),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, [])
      )
    end

    def build_element_list(count)
      Archimate.array_to_id_hash((0..count).map { build_element })
    end

    def build_model(options = {})
      Archimate::Model::Model.new(
        id: options.fetch(:id, Faker::Number.hexadecimal(8)),
        name: options.fetch(:name, Faker::Company.name),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, []),
        elements: options.fetch(:elements, build_element_list(options.fetch(:with_elements, 0))),
        organization: options.fetch(:organization, Archimate::Model::Organization.create),
        relationships: options.fetch(:relationships, {}),
        diagrams: options.fetch(:diagrams, {})
      )
    end

    def build_relationship(options = {})
      Archimate::Model::Relationship.new(
        id: options.fetch(:id, Faker::Number.hexadecimal(8)),
        type: options.fetch(:type, random_relationship_type),
        source: options.fetch(:source, Faker::Number.hexadecimal(8)),
        target: options.fetch(:source, Faker::Number.hexadecimal(8)),
        name: options.fetch(:name, Faker::Company.catch_phrase),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, [])
      )
    end

    def build_folder(options = {})
      Archimate::Model::Folder.new(
        id: options.fetch(:id, Faker::Number.hexadecimal(8)),
        name: options.fetch(:name, Faker::Commerce.department),
        type: options.fetch(:type, random_relationship_type),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, []),
        items: options.fetch(:items, []),
        folders: options.fetch(:folders, {})
      )
    end

    def build_folders(count, min_items: 1, max_items: 10)
      # return {} if count.zero?
      (0..count - 1).each_with_object({}) do |_i, a|
        folder = build_folder(
          items: (0..random(min_items, max_items)).each_with_object([]) { |_i2, a2| a2 << Faker::Number.hexadecimal(8) }
        )
        a[folder.id] = folder
      end
    end

    def build_organization(options = {})
      Archimate::Model::Organization.new(
        folders: options.fetch(:folders, build_folders(options.fetch(:with_folders, 0)))
      )
    end

    def build_bendpoint(options = {})
      Archimate::Model::Bendpoint.new(
        start_x: options.fetch(:start_x, random(0, 1000)),
        start_y: options.fetch(:start_y, random(0, 1000)),
        end_x: options.fetch(:end_x, random(0, 1000)),
        end_y: options.fetch(:end_y, random(0, 1000))
      )
    end

    def random_relationship_type
      @random ||= Random.new(Random.new_seed)
      Archimate::Constants::ELEMENTS[@random.rand(Archimate::Constants::ELEMENTS.size)]
    end

    def random_element_type
      @random ||= Random.new(Random.new_seed)
      Archimate::Constants::ELEMENTS[@random.rand(Archimate::Constants::ELEMENTS.size)]
    end

    def random(min, max)
      @random ||= Random.new(Random.new_seed)
      @random.rand(max - min) + min
    end
  end
end
