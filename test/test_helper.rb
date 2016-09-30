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
      Archimate::DataModel::Bounds.new(
        x: options.fetch(:x, Faker::Number.positive),
        y: options.fetch(:y, Faker::Number.positive),
        width: options.fetch(:width, Faker::Number.positive),
        height: options.fetch(:height, Faker::Number.positive)
      )
    end

    def build_element(options = {})
      Archimate::DataModel::Element.new(
        id: options.fetch(:id, Faker::Number.hexadecimal(8)),
        label: options.fetch(:label, Faker::Company.buzzword),
        type: options.fetch(:type, random_element_type),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, [])
      )
    end

    def build_element_list(count, other_els)
      other_els = other_els.values if other_els.is_a? Hash
      bel = (1..count).map { build_element } + other_els
      Archimate.array_to_id_hash(bel)
    end

    def build_relationship_list(count, other_rels, el_ids)
      Archimate.array_to_id_hash(
        (1..count).map do
          src_id, target_id = el_ids.shift
          build_relationship(source: src_id, target: target_id)
        end + other_rels
      )
    end

    def build_model(options = {})
      given_elements = options.fetch(:elements, [])
      given_element_count = given_elements.size
      el_count = [options.fetch(:with_relationships, 0) * 2, options.fetch(:with_elements, 0) + given_element_count].max
      els = build_element_list(el_count - given_element_count, given_elements)

      el_ids = els.values.map(&:id).each_slice(2).each_with_object([]) { |i, a| a << i }
      given_relationships = options.fetch(:relationships, [])
      rels = build_relationship_list(options.fetch(:with_relationships, 0), given_relationships, el_ids)

      els = build_element_list(options.fetch(:with_elements, 0), options.fetch(:elements, els))
      Archimate::DataModel::Model.new(
        id: options.fetch(:id, Faker::Number.hexadecimal(8)),
        name: options.fetch(:name, Faker::Company.name),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, []),
        elements: els,
        organization: options.fetch(:organization, Archimate::DataModel::Organization.create),
        relationships: rels,
        diagrams: options.fetch(:diagrams, {})
      )
    end

    def build_relationship(options = {})
      Archimate::DataModel::Relationship.new(
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
      Archimate::DataModel::Folder.new(
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
      Archimate::DataModel::Organization.new(
        folders: options.fetch(:folders, build_folders(options.fetch(:with_folders, 0)))
      )
    end

    def build_bendpoint(options = {})
      Archimate::DataModel::Bendpoint.new(
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
