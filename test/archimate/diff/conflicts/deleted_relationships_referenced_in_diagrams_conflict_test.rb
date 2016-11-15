# frozen_string_literal: true
require 'test_helper'

module Archimate
  module Diff
    class Conflicts
      class DeletedRelationshipsReferencedInDiagramsConflictTest < Minitest::Test
        attr_reader :base, :remote, :local, :diagram

        def setup
          @aio = Archimate::AIO.new(uout: StringIO.new, verbose: false)
          @base = build_model(with_relationships: 2, with_diagrams: 1)
          @diagram = base.diagrams.first
          @relationship_id = diagram.relationships.first
          # update diagram that references child
          @remote = base.with(
            diagrams: @base.diagrams.map do |i|
              @diagram.id == i.id ? i.with(name: "I wuz renamed") : i
            end
          )
          # delete relationship from local
          @local = @base.with(
            relationships: @base.relationships.reject { |r| r.id == @relationship_id }
          )
          @base_local_diffs = Archimate.diff(@base, @local)
          @base_remote_diffs = Archimate.diff(@base, @remote)
          @subject = DeletedRelationshipsReferencedInDiagramsConflict.new(@base_local_diffs, @base_remote_diffs)
        end

        def test_filter1_deleted_relationship
          @base_local_diffs.each do |diff|
            assert @subject.filter1.call(diff)
          end
          @base_remote_diffs.each do |diff|
            refute @subject.filter1.call(diff)
          end
        end

        def test_filter2_inserted_or_changed_diagram
          @base_local_diffs.each do |diff|
            refute @subject.filter2.call(diff)
          end
          @base_remote_diffs.each do |diff|
            assert @subject.filter2.call(diff)
          end
        end

        def test_diff_conflicts
          assert @subject.diff_conflicts(@base_local_diffs.first, @base_remote_diffs.first)
        end
      end
    end
  end
end
