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

Minitest::Test.make_my_diffs_pretty!

module Minitest
  class Test
    def build_id
      Faker::Number.hexadecimal(8)
    end

    def build_documentation(options = {})
      options.fetch(:text, [Faker::ChuckNorris.fact])
    end

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
        id: options.fetch(:id, build_id),
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

    def requested_elements(options)
      given_elements = options.fetch(:elements, [])
      given_element_count = given_elements.size
      el_count = [options.fetch(:with_relationships, 0) * 2, options.fetch(:with_elements, 0) + given_element_count].max
      build_element_list(el_count - given_element_count, given_elements)
    end

    def requested_relationships(options, elements)
      build_relationship_list(
        options.fetch(:with_relationships, 0),
        options.fetch(:relationships, []),
        elements.values.map(&:id).each_slice(2).each_with_object([]) { |i, a| a << i }
      )
    end

    def requested_folders(options, _elements)
      build_folders(
        options.fetch(:with_folders, 0)
      )
    end

    def build_model(options = {})
      elements = requested_elements(options)
      relationships = requested_relationships(options, elements)
      diagrams = requested_diagrams(options, elements, relationships)
      folders = requested_folders(options, elements)
      Archimate::DataModel::Model.new(
        id: options.fetch(:id, build_id),
        name: options.fetch(:name, Faker::Company.name),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, []),
        elements: elements,
        folders: options.fetch(:folders, folders),
        relationships: relationships,
        diagrams: diagrams
      )
    end

    def requested_diagrams(options, elements, relationships)
      options.fetch(:diagrams, {})
      child_list = relationships.map do |id, rel|
        [build_child(element: elements[rel.source], relationships: { id => rel }),
         build_child(element: elements[rel.target], relationships: {})]
      end.flatten
      Archimate.array_to_id_hash(build_diagram(children: Archimate.array_to_id_hash(child_list)))
    end

    def build_diagram(options = {})
      children = options.fetch(:children, build_children)
      Archimate::DataModel::Diagram.new(
        id: options.fetch(:id, build_id),
        name: options.fetch(:name, Faker::Commerce.product_name),
        viewpoint: options.fetch(:viewpoint, nil),
        documentation: options.fetch(:documentation, build_documentation),
        properties: options.fetch(:properties, []),
        children: children,
        connection_router_type: nil,
        type: nil,
        element_references: children.each_with_object([]) { |(_id, child), a| a.concat(child.element_references) }
      )
    end

    def build_children(options = {})
      count = options.fetch(:count, 3)
      (1..count).each_with_object({}) do |_i, a|
        child = build_child
        a[child.id] = child
      end
    end

    def build_child(options = {})
      node_element = options.fetch(:element, build_element)
      relationships = options.fetch(:relationships, {})
      Archimate::DataModel::Child.create(
        id: options.fetch(:id, build_id),
        type: "archimate:DiagramObject",
        name: options[:name],
        archimate_element: node_element.id,
        bounds: build_bounds,
        source_connections: relationships.values.map do |rel|
          build_source_connection(for_relationship: rel)
        end,
        style: build_style
      )
    end

    def build_source_connection(options = {})
      relationship = options.fetch(:for_relationship, nil)

      Archimate::DataModel::SourceConnection.create(
        id: options.fetch(:id, build_id),
        type: "archimate:Connection",
        source: options.fetch(:source, relationship&.source || build_id),
        target: options.fetch(:target, relationship&.target || build_id),
        relationship: options.fetch(:relationship, relationship&.id || build_id)
      )
    end

    def build_relationship(options = {})
      Archimate::DataModel::Relationship.new(
        id: options.fetch(:id, build_id),
        type: options.fetch(:type, random_relationship_type),
        source: options.fetch(:source, build_id),
        target: options.fetch(:source, build_id),
        name: options.fetch(:name, Faker::Company.catch_phrase),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, [])
      )
    end

    def build_folder(options = {})
      Archimate::DataModel::Folder.new(
        id: options.fetch(:id, build_id),
        name: options.fetch(:name, Faker::Commerce.department),
        type: options.fetch(:type, random_relationship_type),
        documentation: options.fetch(:documentation, []),
        properties: options.fetch(:properties, []),
        items: options.fetch(:items, []),
        folders: options.fetch(:folders, {})
      )
    end

    def build_folders(count, min_items: 1, max_items: 10, child_folders: {})
      (1..count).each_with_object({}) do |_i, a|
        folder = build_folder(
          items: (0..random(min_items, max_items)).each_with_object([]) { |_i2, a2| a2 << build_id },
          folders: child_folders
        )
        a[folder.id] = folder
      end
    end

    def build_bendpoint(options = {})
      Archimate::DataModel::Bendpoint.new(
        start_x: options.fetch(:start_x, random(0, 1000)),
        start_y: options.fetch(:start_y, random(0, 1000)),
        end_x: options.fetch(:end_x, random(0, 1000)),
        end_y: options.fetch(:end_y, random(0, 1000))
      )
    end

    def build_color(options = {})
      Archimate::DataModel::Color.new(
        r: random(0, 255),
        g: random(0, 255),
        b: random(0, 255),
        a: random(0, 100)
      )
    end

    def build_font(options = {})
      Archimate::DataModel::Font.new(
        name: Faker::Name.name,
        size: random(6, 20),
        style: Faker::Name.name
      )
    end

    def build_style(options = {})
      Archimate::DataModel::Style.new(
        text_alignment: random(0, 2),
        fill_color: build_color,
        line_color: build_color,
        font_color: build_color,
        line_width: random(1, 10),
        font: build_font
      )
    end

    def random_relationship_type
      @random ||= Random.new(Random.new_seed)
      Archimate::Constants::RELATIONSHIPS[@random.rand(Archimate::Constants::RELATIONSHIPS.size)]
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
