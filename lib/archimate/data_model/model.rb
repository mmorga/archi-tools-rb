# frozen_string_literal: true

using Archimate::CoreRefinements

module Archimate
  module DataModel
    # This is the root model type.
    #
    # It is a container for the elements, relationships, diagrams and
    # organizations of the model.
    class Model
      include Comparison

      # @!attribute [r] id
      # @return [String] unique identifier of this model
      model_attr :id
      # @!attribute [r] name
      # @return [LangString] name of the model
      model_attr :name

      # @!attribute [r] documentation
      # @return [PreservedLangString, NilClass] model documentation
      model_attr :documentation, default: nil
      # @!attribute [r] properties
      # @return [Array<Property>] model properties
      model_attr :properties, default: []
      # @!attribute [r] metadata
      # @return [Metadata, NilClass] model metadata
      model_attr :metadata, default: nil
      # @!attribute [r] elements
      # @return [Array<Element>]
      model_attr :elements, default: [], referenceable_list: true
      # @!attribute [r] relationships
      # @return [Array<Relationship>]
      model_attr :relationships, default: [], referenceable_list: true
      # @!attribute [r] organizations
      # @return [Array<Organization>]
      model_attr :organizations, default: [], referenceable_list: true
      # @!attribute [r] property_definitions
      # @return [Array<PropertyDefinition>]
      model_attr :property_definitions, default: [], referenceable_list: true
      # @!attribute [r] version
      # @return [String, NilClass]
      model_attr :version, default: nil
      # @!attribute [r] diagrams
      # @return [Array<Diagram>]
      model_attr :diagrams, default: [], referenceable_list: true
      # @!attribute [r] viewpoints
      # @return [Array<Viewpoint>]
      model_attr :viewpoints, default: [], referenceable_list: true

      # Following attributes are to hold info on where the model came from
      # @!attribute [r] filename
      # @return [String]
      model_attr :filename, default: nil
      # @see Archimate::SUPPORTED_FORMATS
      # @!attribute [r] file_format
      # @return [Symbol, NilClass] supported Archimate format [Archimate::SUPPORTED_FORMATS] or +nil+
      model_attr :file_format, default: nil
      # @!attribute [r] archimate_version
      # @return [Symbol] one of [Archimate::ARCHIMATE_VERSIONS], default +:archimate_3_0+
      model_attr :archimate_version, default: :archimate_3_0

      # @!attribute [r] namespaces
      # @return [Hash]
      model_attr :namespaces, default: {}
      # @!attribute [r] schema_locations
      # @return [Array<String>]
      model_attr :schema_locations, default: []

      # @return [Array<AnyElement>]
      model_attr :other_elements, default: []
      # @return [Array<AnyAttribute>]
      model_attr :other_attributes, default: []

      # Constructor
      def initialize(opts = {})
        super
        rebuild_index
      end

      def lookup(id)
        rebuild_index(id) unless @index_hash.include?(id)
        @index_hash[id]
      end

      # Called only by [Lint::DuplicateEntities]
      def entities
        @index_hash.values
      end

      # Called only by [Diff::Merge]
      def rebuild_index(missing_id = :model_creation_event)
        return self unless missing_id
        @index_hash = build_index
        self
      end

      def to_s
        "#{Archimate::Color.data_model('Model')}<#{id}>[#{Archimate::Color.color(name, %i[white underline])}]"
      end

      # Iterate through the model and ensure that elements, relationships, and
      # diagrams are all present in the model's organizations. If an item is missing
      # then move it into the default top-level element for the item type.
      #
      # @note this is only called by [Diff::Merge]
      def organize
        []
          .concat(elements)
          .concat(relationships)
          .concat(diagrams).each do |item|
            if find_in_organizations(item).nil?
              default_organization = default_organization_for(item)
              default_organization.items.push(item) unless default_organization.items.include?(item)
            end
          end
        self
      end

      # Only used by [Diff::DeletedItemsReferencedConflict]
      def referenced_identified_nodes
        classes = [Diagram, ViewNode, Connection, Organization, Relationship].freeze
        @index_hash
          .values
          .select { |entity| classes.include?(entity.class) }
          .map(&:referenced_identified_nodes)
          .flatten
          .uniq
      end

      # @todo this should move into either Comparison or a Mergeable class
      # Steps to merge
      # merge attributes of each copy into master_entity
      # update references of each copy to reference master_entity instead (where it makes sense)
      # remove reference of each copy from its references
      def merge_entities(master_entity, copies)
        copies.delete(master_entity)
        copies.each do |copy|
          copy.replace_with(master_entity)
          # if !copy.references.empty?
          #   puts "#{copy.class} still referenced by #{copy.references.map { |ref| ref.class.name }.join(", ")}"
          # end
          deregister(copy)
        end
      end

      def replace_item_with(item, replacement)
        case item
        when Organization
          organizations.delete(item)
          organizations << replacement
        when Element
          elements.delete(item)
          elements << replacement
        when Relationship
          relationships.delete(item)
          relationships << replacement
        end
      end

      def make_unique_id
        unique_id = random_id
        unique_id = random_id while @index_hash.key?(unique_id)
        unique_id
      end

      def remove_reference(item)
        case item
        when Element
          elements.delete(item)
        when Relationship
          relationships.delete(item)
        else
          raise "Unhandled remove reference for type #{item.class}"
        end
      end

      Elements.classes.each do |el_cls|
        define_method(el_cls.name.split("::").last.snake_case + "s") do
          elements.select { |el| el.is_a?(el_cls) }
        end
      end

      private

      # Only used by [#find_default_organization]
      def add_organization(type, name)
        raise "Program Error: #{organizations.inspect}" unless organizations.none? { |f| f.type == type || f.name == name }
        organization = Organization.new(
          id: make_unique_id,
          name: LangString.new(name),
          type: type,
          items: [],
          organizations: [],
          documentation: nil
        )
        register(organization, organizations)
        organizations.push(organization)
        organization
      end

      def build_index
        @index_hash = { id => self }
        elements.each { |ref| @index_hash[ref.id] = ref }
        relationships.each { |ref| @index_hash[ref.id] = ref }
        diagrams.each { |dia| @index_hash[dia.id] = index_view_nodes(dia) }
        property_definitions.each { |ref| @index_hash[ref.id] = ref }
        index_organizations(self)
        @index_hash
      end

      def default_organization_for(item)
        case item
        when Element
          case item.layer
          when Layers::Strategy
            find_default_organization("strategy", "Strategy")
          when Layers::Business
            find_default_organization("business", "Business")
          when Layers::Application
            find_default_organization("application", "Application")
          when Layers::Technology
            find_default_organization("technology", "Technology")
          when Layers::Physical
            find_default_organization("physical", "Physical")
          when Layers::Motivation
            find_default_organization("motivation", "Motivation")
          when Layers::Implementation_and_migration
            find_default_organization("implementation_migration", "Implementation & Migration")
          when Layers::Connectors
            find_default_organization("connectors", "Connectors")
          when Layers::Other
            find_default_organization("other", "Other")
          else
            raise StandardError, "Unexpected Element Layer: #{item.layer} for item type #{item.type}"
          end
        when Relationship
          find_default_organization("relations", "Relations")
        when Diagram
          find_default_organization("diagrams", "Views")
        else
          raise StandardError, "Unexpected item type #{item.class}"
        end
      end

      def find_by_class(klass)
        @index_hash.values.select { |item| item.is_a?(klass) }
      end

      def find_default_organization(type, name)
        result = organizations.find { |f| f.type == type }
        return result unless result.nil?
        result = organizations.find { |f| f.name == name }
        return result unless result.nil?
        add_organization(type, name)
      end

      def find_in_organizations(item, _fs = nil)
        find_by_class(DataModel::Organization).select { |f| f.items.include?(item) }.first
      end

      # @todo maybe move to [Organization]
      def index_organizations(ref)
        ref.organizations.each do |org|
          @index_hash[org.id] = index_organizations(org)
        end
        ref
      end

      # @todo maybe move to [ViewNode]
      def index_view_nodes(ref)
        ref.nodes.each do |node|
          @index_hash[node.id] = index_view_nodes(node)
        end
        ref.connections.each { |con| @index_hash[con.id] = con }
        ref
      end

      def random_id
        @random ||= Random.new
        format("%08x", @random.rand(0xffffffff))
      end

      def register(node, _parent)
        @index_hash[node.id] = node
      end

      def deregister(node)
        @index_hash.delete(node.id)
      end
    end
  end
end
