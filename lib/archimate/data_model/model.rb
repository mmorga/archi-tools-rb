# frozen_string_literal: true

module Archimate
  module DataModel
    # This is the root model type.
    # It is a container for the elements, relationships, diagrams and organizations of the model.
    class Model
      include Comparison

      model_attr :id # Identifier
      model_attr :name # LangString

      model_attr :documentation # PreservedLangString.optional.default(nil)
      # model_attr :other_elements # Strict::Array.member(AnyElement).default([])
      # model_attr :other_attributes # Strict::Array.member(AnyAttribute).default([])
      model_attr :properties # Strict::Array.member(Property).default([]) # Properties.optional
      model_attr :metadata # Metadata.optional.default(nil)
      model_attr :elements # Strict::Array.member(Element).default([])
      model_attr :relationships # Strict::Array.member(Relationship).default([])
      model_attr :organizations # Strict::Array.member(Organization).default([])
      model_attr :property_definitions # Strict::Array.member(PropertyDefinition).default([])
      model_attr :version # Strict::String.optional.default(nil)
      model_attr :diagrams # Strict::Array.member(Diagram).default([])
      model_attr :viewpoints # Strict::Array.member(Viewpoint).default([])
      # Following attributes are to hold info on where the model came from
      model_attr :filename # Strict::String.optional.default(nil)
      model_attr :file_format # Strict::Symbol.enum(*Archimate::SUPPORTED_FORMATS).optional.default(nil)
      model_attr :archimate_version # Strict::Symbol.default(:archimate_3_0).enum(*Archimate::ARCHIMATE_VERSIONS)

      model_attr :namespaces # Strict::Hash.default({})
      model_attr :schema_locations # Strict::Array.member(Strict::String).default([])

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
        # self.in_model = self
        # self.parent = nil
        rebuild_index
      end

      def lookup(id)
        rebuild_index(id) unless @index_hash.include?(id)
        @index_hash[id]
      end

      def entities
        @index_hash.values
      end

      def rebuild_index(missing_id = :model_creation_event)
        return self unless missing_id
        @index_hash = build_index
        self
      end

      # TODO: make this private - maybe move to ViewNode
      def index_view_nodes(ref)
        ref.nodes.each do |node|
          @index_hash[node.id] = index_view_nodes(node)
        end
        ref.connections.each { |con| @index_hash[con.id] = con }
        ref
      end

      # TODO: make this private - maybe move to Organization
      def index_organizations(ref)
        ref.organizations.each do |org|
          @index_hash[org.id] = index_organizations(org)
        end
        ref
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

      def register(node, _parent)
        # node.in_model = self
        # node.parent = parent
        @index_hash[node.id] = node
      end

      def deregister(node)
        @index_hash.delete(node.id)
      end

      def find_by_class(klass)
        @index_hash.values.select { |item| item.is_a?(klass) }
      end

      def to_s
        "#{Archimate::Color.data_model('Model')}<#{id}>[#{Archimate::Color.color(name, %i[white underline])}]"
      end

      # TODO: make these DSL like things added dynamically
      def application_components
        elements.select { |element| element.type == "ApplicationComponent" }
      end

      def element_type_names
        elements.map(&:type).uniq
      end

      def elements_with_type(el_type)
        elements.select { |element| element.type == el_type }
      end

      # Iterate through the model and ensure that elements, relationships, and
      # diagrams are all present in the model's organizations. If an item is missing
      # then move it into the default top-level element for the item type.
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

      def find_in_organizations(item, _fs = nil)
        find_by_class(DataModel::Organization).select { |f| f.items.include?(item.id) }.first
      end

      def default_organization_for(item)
        case item
        when Element
          case item.layer
          when "Strategy"
            find_default_organization("strategy", "Strategy")
          when "Business"
            find_default_organization("business", "Business")
          when "Application"
            find_default_organization("application", "Application")
          when "Technology"
            find_default_organization("technology", "Technology")
          when "Physical"
            find_default_organization("physical", "Physical")
          when "Motivation"
            find_default_organization("motivation", "Motivation")
          when "Implementation and Migration"
            find_default_organization("implementation_migration", "Implementation & Migration")
          when "Connectors"
            find_default_organization("connectors", "Connectors")
          else
            raise StandardError, "Unexpected Element Layer: #{item.layer.inspect} for item type #{item.type.inspect}"
          end
        when Relationship
          find_default_organization("relations", "Relations")
        when Diagram
          find_default_organization("diagrams", "Views")
        else
          raise StandardError, "Unexpected item type #{item.class}"
        end
      end

      def find_default_organization(type, name)
        result = organizations.find { |f| f.type == type }
        return result unless result.nil?
        result = organizations.find { |f| f.name == name }
        return result unless result.nil?
        add_organization(type, name)
      end

      def add_organization(type, name)
        raise "Program Error: #{organizations.inspect}" unless organizations.none? { |f| f.type == type || f.name == name }
        organization = Organization.new(id: make_unique_id, name: LangString.create(name), type: type, items: [], organizations: [], documentation: nil)
        register(organization, organizations)
        organizations.push(organization)
        organization
      end

      def make_unique_id
        unique_id = random_id
        unique_id = random_id while @index_hash.key?(unique_id)
        unique_id
      end

      def struct_instance_variables
        self.class.schema.keys
      end

      def referenced_identified_nodes
        classes = [Diagram, ViewNode, Connection, Organization, Relationship].freeze
        @index_hash
          .values
          .select { |entity| classes.include?(entity.class) }
          .map(&:referenced_identified_nodes)
          .flatten
          .uniq
      end

      def identified_nodes
        @index_hash.values.select { |node| node.respond_to? :id }
      end

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

      private

      def random_id
        @random ||= Random.new
        format("%08x", @random.rand(0xffffffff))
      end
    end
  end
end
