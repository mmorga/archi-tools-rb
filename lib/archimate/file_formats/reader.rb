# frozen_string_literal: true
require "nokogiri"

module Archimate
  module FileFormats
    class Reader
      attr_reader :index
      attr_reader :doc
      attr_reader :archimate_default_lang

      def initialize(doc)
        @doc = doc
        @index = {}
        @progress = nil
        @random ||= Random.new
        @property_defs = {}
        @diagram_stack = []
        @archimate_default_lang = Archimate::Config.instance.default_lang
      end

      def show_progress
        return unless block_given?
        job_size = 0
        doc.traverse { |_n| job_size += 1 }
        @progress = ProgressIndicator.new(total: job_size, title: "Parsing")
        tick
        yield
      ensure
        @progress&.finish
        @progress = nil
      end

      def tick
        @progress&.increment
      end

      def register(ref)
        index[ref.id] = ref
        ref
      end

      def parse
        show_progress { parse_model(doc.root) }
      end

      def parse_documentation(node, element_name = "documentation")
        lang_hash = node
          .children
          .filter(element_name)
          .reduce(Hash.new { |hash, key| hash[key] = [] }) do |hash, doc|
            tick
            lang = doc["xml:lang"] # || archimate_default_lang
            hash[lang] << doc.content
            hash
          end
          .transform_values { |ary| ary.join("\n") }
        return nil if lang_hash.empty?
        default_lang = lang_hash.keys.first
        default_text = lang_hash[default_lang]
        DataModel::PreservedLangString.new(
          lang_hash: lang_hash,
          default_lang: default_lang,
          default_text: default_text
        )
      end

      def parse_properties(node)
        node
          .children
          .filter("property")
          .map { |i| parse_property(i) }
      end

      def parse_elements(model)
        element_nodes(model)
          .map { |i| parse_element(i) }
      end

      def parse_organizations(node)
        node
          .children
          .filter("folder").map do |i|
            parse_organization(i)
          end
      end

      def parse_relationships(model)
        relationship_nodes(model)
          .map { |i| parse_relationship(i) }
      end

      def parse_diagrams(model)
        diagram_nodes(model)
          .map { |i| parse_diagram(i) }
      end

      def parse_view_nodes(node)
        node
          .children
          .filter("child")
          .map { |child_node| parse_view_node(child_node) }
      end

      def parse_connections(node)
        node
          .children
          .filter("sourceConnection")
          .map { |i| parse_connection(i) }
      end
    end
  end
end
