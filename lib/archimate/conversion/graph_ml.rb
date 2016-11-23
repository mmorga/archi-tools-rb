# frozen_string_literal: true
# This module takes an ArchiMate model and builds GraphML representation of it.
require "set"

module Archimate
  module Conversion
    class GraphML
      attr_reader :model

      def initialize(model)
        @model = model
      end

      def to_graph_ml
        @prop_id = 1
        @edge_id = 1
        @layers = Hash.new do |hash, key|
          hash[key] = [] unless hash.key?(key)
          hash[key]
        end
        builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
          xml.graphml(
            "xmlns" => "http://graphml.graphdrawing.org/xmlns",
            "xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
            "xsi:schemaLocation" => "http://graphml.graphdrawing.org/xmlns http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd"
          ) do
            xml.key(id: "element-type", for: "node", "attr.name" => "type", "attr.type" => "string")
            xml.key(id: "relationship-type", for: "edge", "attr.name" => "type", "attr.type" => "string")
            xml.key(id: "name", for: "all", "attr.name" => "name", "attr.type" => "string")
            xml.key(id: "documentation", for: "all", "attr.name" => "documentation", "attr.type" => "string")
            xml.key(id: "property-value", for: "all", "attr.name" => "value", "attr.type" => "string")
            xml.graph(
              id: model.id,
              edgedefault: "directed"
            ) do
              graph_attrs(xml, model)
              nodes(xml, model.elements)
              layers(xml, @layers)
              relationships(xml, model.relationships)
            end
          end
        end
        builder.to_xml
      end

      def next_prop_id
        @prop_id += 1
        "property-#{@prop_id}"
      end

      def next_edge_id
        @edge_id += 1
        "edge-#{@edge_id}"
      end

      def graph_attrs(xml, model)
        name(xml, model.name)
        docs(xml, model.documentation)
        properties(xml, model.id, model.properties)
      end

      def name(xml, name_str)
        data(xml, "name", name_str) unless name_str.nil?
      end

      def data_type(xml, key, type)
        data(xml, key, type.nil? ? nil : type.sub("archimate:", ""))
      end

      def data(xml, key, value)
        xml.data(key: key) { xml.text(value) unless value.nil? }
      end

      def properties(xml, source_id, properties)
        properties.each do |property|
          # TODO: if we want to be slick here, keep a set of property values and point to that instead
          prop_id = next_prop_id
          node(xml, prop_id, property.key, "Property", "property-value" => property.value)
          edge(xml, next_edge_id, source_id, prop_id, "HasProperty", property.key)
        end
      end

      def docs(xml, docs)
        docs.each do |doc|
          data(xml, "documentation", doc)
        end
      end

      def nodes(xml, elements)
        elements.each do |element|
          node(xml, element.id, element.name, element.type, element.documentation, element.properties)

          @layers[element.layer] << element.id
        end
      end

      def layers(xml, layers)
        layers.each_with_index do |layer, i|
          node(xml, "layer-#{i}", layer, "Layer")
        end
      end

      def relationships(xml, relationships)
        relationships.each do |r|
          edge(xml, r.id, r.source, r.target, r.type, r.name, r.documentation, r.properties)
        end
      end

      def node(xml, id, name, type, docs = [], properties = [], other_data = {})
        xml.node(id: id, label: name, labels: "#{type}:#{name}") do
          data_type(xml, "element-type", type)
          name(xml, name)
          docs(xml, docs)
          other_data.each do |k, v|
            xml.data(key: k) { xml.text(v) }
          end
        end
        properties(xml, id, properties)
      end

      def edge(xml, id, source, target, type, name = nil, docs = [], properties = [])
        xml.edge(id: id, source: source, target: target, label: type) do
          data_type(xml, "relationship-type", type)
          name(xml, name)
          docs(xml, docs)
        end
        properties(xml, id, properties)
      end
    end
  end
end
