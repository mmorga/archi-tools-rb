# frozen_string_literal: true

using Archimate::CoreRefinements

module Archimate
  module DataModel
    # RelationshipReferences provides a means to allow a class that is referenced
    # by Relationship objects to get the set of:
    # * All relationships
    # * All relationships by:
    #   - a particular type
    #   - if this object is the source of target of the relationship
    module RelationshipReferences
      def relationships
        references.select { |ref| ref.is_a?(DataModel::Relationship) }
      end

      # Creates a method on this instance that returns the relationships of the
      # relationship type `rel_cls` where this object is the source.
      #
      # @param rel_cls [Archimate::DataModel::Relationship] Relationships class to define references method
      def self.define_typed_relationships_method(rel_cls)
        define_method(rel_cls::VERB.to_method_name("relationships")) do
          references.select { |ref| ref.is_a?(rel_cls) && ref.source == self }
        end
      end

      # Creates a method on this instance that returns the elements related by the
      # relationship type `rel_cls` where this object is the source.
      #
      # @param rel_cls [Archimate::DataModel::Relationship] Relationships class to define references method
      def self.define_typed_elements_method(rel_cls)
        define_method(rel_cls::VERB.to_method_name("elements")) do
          references
            .select { |ref| ref.is_a?(rel_cls) && ref.source == self }
            .map(&:target)
        end
      end

      # Creates a method on this instance that returns the relationships of the
      # relationship type `rel_cls` where this object is the target.
      #
      # @param rel_cls [Archimate::DataModel::Relationship] Relationships class to define references method
      def self.define_typed_targeted_relationships_method(rel_cls)
        define_method(rel_cls::OBJECT_VERB.to_method_name("relationships")) do
          references.select { |ref| ref.is_a?(rel_cls) && ref.target == self }
        end
      end

      # Creates a method on this instance that returns the elements related by the
      # relationship type `rel_cls` where this object is the source.
      #
      # @param rel_cls [Archimate::DataModel::Relationship] Relationships class to define references method
      def self.define_typed_targeted_elements_method(rel_cls)
        define_method(rel_cls::OBJECT_VERB.to_method_name("elements")) do
          references
            .select { |ref| ref.is_a?(rel_cls) && ref.target == self }
            .map(&:source)
        end
      end

      # Creates a method on this instance to create relationships to one or more
      # elements of a the rel_cls relationship type where this object is source.
      #
      # @param rel_cls [Archimate::DataModel::Relationship] Relationships class to define references method
      def self.define_source_relationship_creation_method(rel_cls)
        define_method(rel_cls::VERB.to_method_name) do |targets = nil, args = {}|
          rels = Array(args.fetch(:target, targets)).compact.map do |target|
            rargs = args.dup
            rargs[:target] = target
            rargs[:source] = self
            rargs[:id] = model.make_unique_id if !rargs.key?(:id) && model
            relationship = rel_cls.new(rargs)
            (model.relationships << relationship) if model
            relationship
          end
          rels.size < 2 ? rels.first : rels
        end
      end

      # Creates a method on this instance to create relationships to one or more
      # elements of a the rel_cls relationship type where this object is target.
      #
      # @param rel_cls [Archimate::DataModel::Relationship] Relationships class to define references method
      def self.define_target_relationship_creation_method(rel_cls)
        define_method(rel_cls::OBJECT_VERB.to_method_name) do |sources = nil, args = {}|
          rels = Array(args.fetch(:source, sources)).compact.map do |source|
            rargs = args.dup
            rargs[:source] = source
            rargs[:target] = self
            rargs[:id] = model.make_unique_id if !rargs.key?(:id) && model
            relationship = rel_cls.new(rargs)
            (model.relationships << relationship) if model
            relationship
          end
          rels.size < 2 ? rels.first : rels
        end
      end

      def self.included(_base)
        Relationships.classes.each do |rel_cls|
          define_typed_relationships_method(rel_cls)
          define_typed_elements_method(rel_cls)
          define_typed_targeted_relationships_method(rel_cls)
          define_typed_targeted_elements_method(rel_cls)
          define_source_relationship_creation_method(rel_cls)
          define_target_relationship_creation_method(rel_cls)
        end
      end
    end
  end
end
