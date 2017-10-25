# frozen_string_literal: true

module Archimate
  module DataModel
    # This is the root model type.
    #
    # It is a container for the elements, relationships, diagrams and
    # organizations of the model.
    class Model
      include Comparison

      # @!attribute [r] id
      #   @return [String] unique identifier of this model
      model_attr :id
      # @!attribute [r] name
      #   @return [LangString] name of the model
      model_attr :name

      # @!attribute [r] documentation
      #   @return [PreservedLangString, NilClass] model documentation
      model_attr :documentation
      # @!attribute [r] properties
      #   @return [Array<Property>] model properties
      model_attr :properties
      # @!attribute [r] metadata
      #   @return [Metadata, NilClass] model metadata
      model_attr :metadata
      # @!attribute [r] elements
      #   @return [Array<Element>]
      model_attr :elements
      # @!attribute [r] relationships
      #   @return [Array<Relationship>]
      model_attr :relationships
      # @!attribute [r] organizations
      #   @return [Array<Organization>]
      model_attr :organizations
      # @!attribute [r] property_definitions
      #   @return [Array<PropertyDefinition>]
      model_attr :property_definitions
      # @!attribute [r] version
      #   @return [String, NilClass]
      model_attr :version
      # @!attribute [r] diagrams
      #   @return [Array<Diagram>]
      model_attr :diagrams
      # @!attribute [r] viewpoints
      #   @return [Array<Viewpoint>]
      model_attr :viewpoints

      # Following attributes are to hold info on where the model came from
      # @!attribute [r] filename
      #   @return [String]
      model_attr :filename
      # @see Archimate::SUPPORTED_FORMATS
      # @!attribute [r] file_format
      #   @return [Symbol, NilClass] supported Archimate format [Archimate::SUPPORTED_FORMATS] or +nil+
      model_attr :file_format
      # @!attribute [r] archimate_version
      #   @return [Symbol] one of [Archimate::ARCHIMATE_VERSIONS], default +:archimate_3_0+
      model_attr :archimate_version

      # @!attribute [r] namespaces
      #   @return [Hash]
      model_attr :namespaces
      # @!attribute [r] schema_locations
      #   @return [Array<String>]
      model_attr :schema_locations

      # # @return [Array<AnyElement>]
      # model_attr :other_elements
      # # @return [Array<AnyAttribute>]
      # model_attr :other_attributes

      # Constructor
      def initialize(id:, name:, documentation: nil, properties: [],
                     metadata: nil, elements: [], relationships: [],
                     organizations: [], property_definitions: [],
                     version: nil, diagrams: [], viewpoints: [],
                     filename: nil, file_format: nil, archimate_version: :archimate_3_0,
                     namespaces: {}, schema_locations: [])
        @id = id
        @name = name
        @documentation = documentation
        @properties = properties
        @metadata = metadata
        @elements = elements
        @relationships = relationships
        @organizations = organizations
        @property_definitions = property_definitions
        @version = version
        @diagrams = diagrams
        @viewpoints = viewpoints
        @filename = filename
        @file_format = file_format
        @archimate_version = archimate_version
        @namespaces = namespaces
        @schema_locations = schema_locations
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
              default_organization.items.push(item.id) unless default_organization.items.include?(item.id)
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

      # This is used only by the model [Cli::Cleanup] class.
      def unreferenced_nodes
        identified_nodes - referenced_identified_nodes
      end

      # def merge_entities(master_entity, copies)
      #   copies.delete(master_entity)
      #   copies.each do |copy|
      #     entities.each do |entity|
      #       case entity
      #       when entity == master_entity
      #         master_entity.merge(copy)
      #       when Organization
      #         entity.remove(copy.id)
      #       when ViewNode, Relationship, Connection
      #         entity.replace(copy, master_entity)
      #       end
      #     end
      #     deregister(copy)
      #   end
      # end

      def make_unique_id
        unique_id = random_id
        unique_id = random_id while @index_hash.key?(unique_id)
        unique_id
      end

      private

      # Only used by [#find_default_organization]
      def add_organization(type, name)
        raise "Program Error: #{organizations.inspect}" unless organizations.none? { |f| f.type == type || f.name == name }
        organization = Organization.new(id: make_unique_id, name: LangString.create(name), type: type, items: [], organizations: [], documentation: nil)
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
        find_by_class(DataModel::Organization).select { |f| f.items.include?(item.id) }.first
      end

      # Only used by [#unreferenced_nodes]
      def identified_nodes
        @index_hash.values.select { |node| node.respond_to? :id }
      end

      # @todo make this private - maybe move to [Organization]
      def index_organizations(ref)
        ref.organizations.each do |org|
          @index_hash[org.id] = index_organizations(org)
        end
        ref
      end

      # @todo make this private - maybe move to [ViewNode]
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
