# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Cli
    class MergerTest < Minitest::Test
      def setup
        file1 = File.join(TEST_EXAMPLES_FOLDER, "merger_1_1.archimate")
        file2 = File.join(TEST_EXAMPLES_FOLDER, "merger_1_2.archimate")
        @doc = Merger.new.merge_files(file1, file2)
      end

      def test_that_doc1_keeps_root_node
        assert_equal "b51ba1e9", @doc.root["id"]
        assert_equal "merger-case-1", @doc.root["name"]
      end

      def test_that_business_organization_gets_contents_from_doc2
        business_organization = @doc.at_css("archimate|model > folder[name=\"Business\"][id=\"2d5248d5\"][type=\"business\"]")
        refute_nil business_organization
        assert_equal 2, business_organization.children.size

        refute_nil business_organization.at_css(">element[id=\"b2908253\"][name=\"Neo\"][type=\"archimate:BusinessActor\"]")
        refute_nil business_organization.at_css(">element[id=\"3e87b4fa\"][name=\"The One\"][type=\"archimate:BusinessRole\"]")
      end

      def test_that_application_organization_keeps_original_content
        application_organization = @doc.at_css("archimate|model > folder[name=\"Application\"][id=\"6dbb97fa\"][type=\"application\"]")
        refute_nil application_organization
        hal_9000 = application_organization.at_css("> folder[name=\"HAL9000\"][id=\"cde1a30a\"]")
        refute_nil hal_9000, "Expected HAL 9000 Organization"
        refute_nil hal_9000.at_css(">element[id=\"f8f873d0\"][name=\"HAL\"][xsi|type=\"archimate:ApplicationComponent\"]"), "Expected HAL Application Component from doc2"
      end

      def test_that_cool_tech_contents_are_correct
        tech_organization = @doc.at_css("archimate|model > folder[name=\"Technology\"][id=\"6e2ca6a8\"][type=\"technology\"]")
        cool_tech_organization = tech_organization.at_css(">folder[name=\"Cool Tech\"][id=\"64bb82ea\"]")
        refute_nil cool_tech_organization, "Cool Tech Organization expected"
        assert_equal 3, cool_tech_organization.children.select { |e| e.name == "element" }.size
        refute_nil cool_tech_organization.at_css(">element[id=\"5152f0ba\"][name=\"Lulz\"][xsi|type=\"archimate:Artifact\"]"), "Expected Lulz Artifact from doc1"
        refute_nil cool_tech_organization.at_css(">element[id=\"3045354e\"][name=\"Tesseract\"][xsi|type=\"archimate:Device\"]"), "Expected Tesseract Device"
        refute_nil cool_tech_organization.at_css(">element[id=\"51675910\"][name=\"The Fridge\"][xsi|type=\"archimate:Node\"]"), "Expected The Fridge Node"
      end

      def test_unique_tech_organization
        unique_tech_organization = @doc.at_css("archimate|model > folder[name=\"Technology\"][id=\"6e2ca6a8\"][type=\"technology\"] > folder[name=\"Unique Tech\"][id=\"bf4ca172\"]")
        refute_nil unique_tech_organization, "Expected Unique Tech organization from doc2"
        refute_nil unique_tech_organization.at_css(">element[id=\"facf9629\"][name=\"FTL API\"][type=\"archimate:InfrastructureInterface\"]"), "Expected FTL API Infrastructure Interface from doc2"
      end

      def test_relations_organization
        relations_organization = @doc.at_css("archimate|model > folder[name=\"Relations\"][id=\"996f61e9\"][type=\"relations\"]")
        refute_nil relations_organization, "Expected Relations organization from doc1"
        refute_nil relations_organization.at_css(">element[id=\"25c854cd\"][source=\"b2908253\"][target=\"3e87b4fa\"][type=\"archimate:AssignmentRelationship\"]"), "Expected AssignmentRelationship from doc2"
      end

      def test_views_organization
        views_organization = @doc.at_css("archimate|model > folder[name=\"Views\"][id=\"9d6bea86\"][type=\"diagrams\"]")
        refute_nil views_organization, "Expected Views organization from doc1"
        refute_nil views_organization.at_css(">element[id=\"eca078f9\"][name=\"Default View\"][xsi|type=\"archimate:ArchimateDiagramModel\"]"), "Expected Default View from doc1"
      end
    end
  end
end
