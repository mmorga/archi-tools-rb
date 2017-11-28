# frozen_string_literal: true

require 'test_helper'
require "test_examples"

module Archimate
  class DedupeTest < Minitest::Test
    def test_referenceable
      archisurance_model.relationships.each do |rel|
        assert(rel.source.references.include?(rel))
        assert(rel.target.references.include?(rel))
      end
    end

    def element_by_type_and_name(type, name)
      type = DataModel::Elements.const_get(type) if type.is_a?(Symbol)
      ->(el) { el.is_a?(type) && el.name.to_s == name }
    end

    def relationship_by_type_and_name(type, name)
      type = DataModel::Relationships.const_get(type) if type.is_a?(Symbol)
      ->(el) { el.is_a?(type) && el.name.to_s == name }
    end

    def test_dedupe_archi_format
      Dir.mktmpdir do |dir|
        deduped_file = File.join(dir, "deduped.archimate")
        _out, err = capture_io do
          Cli::Archi.start ["dedupe", "-m", "-o", deduped_file, "test/examples/archisurance.archimate"]
        end

        src = File.read(deduped_file)
        lines = src.split("\n")
        %w[1536 1059 1101 1004 90702769].each do |id|
          refute_match "\"#{id}\"", lines.select { |line| line =~ /"#{id}"/ }.join("\n")
        end
        assert_empty err
        model = Archimate.parse(src)
        assert_equal(
          1,
          model.elements.select do |el|
            el.is_a?(DataModel::Elements::BusinessInterface) && el.name.to_s == "phone"
          end.size
        )
        # BusinessInterface has potential duplicates: <1540>[phone], <1536>[phone]
        assert(model.elements.none? { |el| el.id == "1536" })
        # Device has potential duplicates: <1053>[Unix Server], <1059>[Unix Server]
        # assert_equal 1, model.elements.select { |el| el.is_a?(DataModel::Elements::Device) && el.name.to_s == "Unix Server" }.size
        assert_equal 1, model.elements.select(&element_by_type_and_name(:Device, "Unix Server")).size
        assert(model.elements.none? { |el| el.id == "1059" })
        # Network has potential duplicates: <1089>[LAN], <1101>[LAN]
        assert(model.elements.none? { |el| el.id == "1101" })
        assert_equal 1, model.elements.select(&element_by_type_and_name(:Network, "LAN")).size
        # Node has potential duplicates: <998>[Firewall], <1004>[Firewall]
        assert_equal 1, model.elements.select(&element_by_type_and_name(:Node, "Firewall")).size
        assert(model.elements.none? { |el| el.id == "1004" })
        # Access has potential duplicates: <712>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File],
        #                                  <90702769>[update] BusinessProcess<588>[Pay] -> BusinessObject<674>[Customer File]
        assert_equal 1, model.relationships.select(&relationship_by_type_and_name(:Access, "update")).size
        assert(model.elements.none? { |el| el.id == "90702769" })
      end
    end

    def test_dedupe_archi_format_variations
      Dir.mktmpdir do |tmpdir|
        outfile = File.join(tmpdir, "deduped.archimate")
        out, err = capture_io do
          Cli::Archi.start ["dedupe", "-m", "-o", outfile, "--force", "test/examples/duplication.archimate"]
        end
        assert_empty err
        assert_empty out

        model = Archimate.read(outfile)

        prop1def = model.property_definitions.find { |pd| pd.name.to_s == "prop1" }
        refute_nil prop1def
        prop2def = model.property_definitions.find { |pd| pd.name.to_s == "prop2" }
        refute_nil prop2def
        prop3def = model.property_definitions.find { |pd| pd.name.to_s == "prop3" }
        refute_nil prop3def

        assert_equal 1, model.application_components.size
        ac = model.application_components.first
        assert_equal "Application Component", ac.name.to_s
        assert_equal "Existing documentation should still be present", ac.documentation.to_s
        refute_nil(ac.properties.find { |prop| prop.key.to_s == "prop1" && prop.value.to_s == "prop1val" })
        refute_nil(ac.properties.find { |prop| prop.key.to_s == "prop2" && prop.value.to_s == "prop2val" })

        assert_equal 1, model.application_interfaces.size
        ai = model.application_interfaces.first
        assert_equal "Application Interface", ai.name.to_s
        assert_equal "Merged documentation should still be there", ai.documentation.to_s
        refute_nil(ai.properties.find { |prop| prop.key.to_s == "prop1" && prop.value.to_s == "prop1val" })
        refute_nil(ai.properties.find { |prop| prop.key.to_s == "prop2" && prop.value.to_s == "prop2val" })

        assert_equal 1, model.application_services.size
        as = model.application_services.first
        assert_equal "Application Service", as.name.to_s
        assert_nil as.documentation

        af = model.application_functions.first
        assert_equal 1, model.application_functions.size
        assert_equal "Application Function", af.name.to_s
        assert_equal "When both have documentation\nThe documentation should be merged", af.documentation.to_s
        refute_nil(af.properties.find { |prop| prop.key.to_s == "prop1" && prop.value.to_s == "prop1val" })
        refute_nil(af.properties.find { |prop| prop.key.to_s == "prop2" && prop.value.to_s == "prop2val" })
        refute_nil(af.properties.find { |prop| prop.key.to_s == "prop2" && prop.value.to_s == "prop2altval" })
        refute_nil(af.properties.find { |prop| prop.key.to_s == "prop3" && prop.value.to_s == "prop3val" })

        assert_equal 1, model.relationships.size
      end
    end
  end
end
