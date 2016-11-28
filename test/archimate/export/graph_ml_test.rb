# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Export
    class GraphMLTest < Minitest::Test
      def test_graphml
        model = build_model(with_relationships: 2, with_diagrams: 2, with_elements: 4, with_folders: 4)
        model.elements.first.properties << build_property << build_property
        model.elements.first.documentation << build_documentation << build_documentation
        subject = GraphML.new(model)

        result = subject.to_graphml

        doc = Nokogiri::XML(result)
        refute_nil doc
      end
    end
  end
end
