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

      def self.included(_base)
        Relationships.classes.each do |rel_cls|
          define_method(rel_cls::VERB.to_method_name("relationships")) do
            references.select { |ref| ref.is_a?(rel_cls) && ref.source == self }
          end

          define_method(rel_cls::VERB.to_method_name("elements")) do
            references
              .select { |ref| ref.is_a?(rel_cls) && ref.source == self }
              .map(&:target)
          end

          define_method(rel_cls::OBJECT_VERB.to_method_name("relationships")) do
            references.select { |ref| ref.is_a?(rel_cls) && ref.target == self }
          end

          define_method(rel_cls::OBJECT_VERB.to_method_name("elements")) do
            references
              .select { |ref| ref.is_a?(rel_cls) && ref.target == self }
              .map(&:source)
          end

          define_method(rel_cls::VERB.to_method_name) do |target = nil, args = {}|
            args[:target] = target unless args.key?(:target) || !target
            args[:source] = self
            args[:id] = model.make_unique_id if !args.key?(:id) && model
            relationship = rel_cls.new(args)
            model.relationships << relationship if model
            relationship
          end

          define_method(rel_cls::OBJECT_VERB.to_method_name) do |source = nil, args = {}|
            args[:source] = source unless args.key?(:source) || !source
            args[:target] = self
            args[:id] = model.make_unique_id if !args.key?(:id) && model
            relationship = rel_cls.new(args)
            model.relationships << relationship if model
            relationship
          end
        end
      end
    end
  end
end
