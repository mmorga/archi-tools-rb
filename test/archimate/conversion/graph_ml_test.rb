# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Conversion
    class GraphMLTest < Minitest::Test
      def test_graph_ml
        model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        model.elements.first.properties << build_property << build_property
        model.elements.first.documentation << build_documentation_list
        subject = GraphML.new(model)

        result = subject.to_graph_ml

        doc = Nokogiri::XML(result)
        refute_nil doc
      end
    end
  end
end
