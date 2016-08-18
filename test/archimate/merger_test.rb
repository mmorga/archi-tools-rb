require 'test_helper'

module Archimate
  class MergerTest < Minitest::Test
    MERGER_TEST_CASE_DIR = File.join(File.dirname(__FILE__), "..", "merger_cases")
    def setup
      file1 = File.join(MERGER_TEST_CASE_DIR, "merger_1_1.archimate")
      file2 = File.join(MERGER_TEST_CASE_DIR, "merger_1_2.archimate")
      @doc = Merger.new.merge_files(file1, file2)
    end

    def test_that_doc1_keeps_root_node
      assert_equal "b51ba1e9", @doc.root["id"]
      assert_equal "merger-case-1", @doc.root["name"]
    end

    def test_that_business_folder_gets_contents_from_doc2
      business_folder = @doc.at_css("archimate|model > folder[name=\"Business\"][id=\"2d5248d5\"][type=\"business\"]")
      refute_nil business_folder
      assert_equal 2, business_folder.children.size

      refute_nil business_folder.at_css(">element[id=\"b2908253\"][name=\"Neo\"][type=\"archimate:BusinessActor\"]")
      refute_nil business_folder.at_css(">element[id=\"3e87b4fa\"][name=\"The One\"][type=\"archimate:BusinessRole\"]")
    end

    def test_that_application_folder_keeps_original_content
      application_folder = @doc.at_css("archimate|model > folder[name=\"Application\"][id=\"6dbb97fa\"][type=\"application\"]")
      refute_nil application_folder
      hal_9000 = application_folder.at_css("> folder[name=\"HAL9000\"][id=\"cde1a30a\"]")
      refute_nil hal_9000, "Expected HAL 9000 Folder"
      refute_nil hal_9000.at_css(">element[id=\"f8f873d0\"][name=\"HAL\"][xsi|type=\"archimate:ApplicationComponent\"]"), "Expected HAL Application Component from doc2"
    end

    def test_that_cool_tech_contents_are_correct
      tech_folder = @doc.at_css("archimate|model > folder[name=\"Technology\"][id=\"6e2ca6a8\"][type=\"technology\"]")
      cool_tech_folder = tech_folder.at_css(">folder[name=\"Cool Tech\"][id=\"64bb82ea\"]")
      refute_nil cool_tech_folder, "Cool Tech Folder expected"
      assert_equal 3, cool_tech_folder.children.select { |e| e.name == "element" }.size
      refute_nil cool_tech_folder.at_css(">element[id=\"5152f0ba\"][name=\"Lulz\"][xsi|type=\"archimate:Artifact\"]"), "Expected Lulz Artifact from doc1"
      refute_nil cool_tech_folder.at_css(">element[id=\"3045354e\"][name=\"Tesseract\"][xsi|type=\"archimate:Device\"]"), "Expected Tesseract Device"
      refute_nil cool_tech_folder.at_css(">element[id=\"51675910\"][name=\"The Fridge\"][xsi|type=\"archimate:Node\"]"), "Expected The Fridge Node"
    end

    def test_unique_tech_folder
      unique_tech_folder = @doc.at_css("archimate|model > folder[name=\"Technology\"][id=\"6e2ca6a8\"][type=\"technology\"] > folder[name=\"Unique Tech\"][id=\"bf4ca172\"]")
      refute_nil unique_tech_folder, "Expected Unique Tech folder from doc2"
      refute_nil unique_tech_folder.at_css(">element[id=\"facf9629\"][name=\"FTL API\"][type=\"archimate:InfrastructureInterface\"]"), "Expected FTL API Infrastructure Interface from doc2"
    end

    def test_relations_folder
      relations_folder = @doc.at_css("archimate|model > folder[name=\"Relations\"][id=\"996f61e9\"][type=\"relations\"]")
      refute_nil relations_folder, "Expected Relations folder from doc1"
      refute_nil relations_folder.at_css(">element[id=\"25c854cd\"][source=\"b2908253\"][target=\"3e87b4fa\"][type=\"archimate:AssignmentRelationship\"]"), "Expected AssignmentRelationship from doc2"
    end

    def test_views_folder
      views_folder = @doc.at_css("archimate|model > folder[name=\"Views\"][id=\"9d6bea86\"][type=\"diagrams\"]")
      refute_nil views_folder, "Expected Views folder from doc1"
      refute_nil views_folder.at_css(">element[id=\"eca078f9\"][name=\"Default View\"][xsi|type=\"archimate:ArchimateDiagramModel\"]"), "Expected Default View from doc1"
    end
  end
end
