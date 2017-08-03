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
          .css(">#{element_name}")
          .reduce(Hash.new { |hash, key| hash[key] = [] }) do |hash, doc|
            tick
            lang = doc["xml:lang"] || archimate_default_lang
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
        node.css(properties_selector).map do |i|
          parse_property(i)
        end
      end

      def parse_elements(model)
        element_nodes(model)
          .map { |i| lookup_or_parse(i) }
      end

      def parse_organizations(node)
        node.css(organizations_selector).map do |i|
          lookup_or_parse(i)
        end
      end

      def organization_items(node)
        node.css(">element[id]").map do |i, a|
          tick
          lookup_or_parse(i.attr("id"))
        end
      end

      def parse_relationships(model)
        relationship_nodes(model)
          .map { |i| lookup_or_parse(i) }
      end

      def parse_diagrams(model)
        diagram_nodes(model)
          .map { |i| lookup_or_parse(i) }
      end

      def parse_view_nodes(node)
        node
          .css(view_nodes_selector)
          .map { |child_node| lookup_or_parse(child_node) }
      end

      def parse_connections(node)
        node
          .css(connections_selector)
          .map { |i| lookup_or_parse(i) }
      end
    end
  end
end
