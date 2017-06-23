# frozen_string_literal: true

module Archimate
  module DataModel
    # This is the root model type.
    # It is a container for the elements, relationships, diagrams and organizations of the model.
    class Model < NamedReferenceable
      using DataModel::DiffableArray
      using DataModel::DiffablePrimitive

      ARRAY_RE = Regexp.compile(/\[(\d+)\]/)

      attribute :properties, Strict::Array.member(Property).default([]) # Properties.optional
      attribute :metadata, Metadata.optional
      attribute :elements, Strict::Array.member(Element).default([])
      attribute :relationships, Strict::Array.member(Relationship).default([])
      attribute :organizations, Strict::Array.member(Organization).default([])
      attribute :property_definitions, Strict::Array.member(PropertyDefinition).default([])
      attribute :version, Strict::String.optional
      attribute :diagrams, Strict::Array.member(Diagram).default([])
      attribute :viewpoints, Strict::Array.member(Viewpoint).default([])
      # Following attributes are to hold info on where the model came from
      attribute :filename, Strict::String.optional
      attribute :file_format, Strict::Symbol.enum(*Archimate::SUPPORTED_FORMATS).optional
      attribute :archimate_version, Strict::Symbol.default(:archimate_3_0).enum(*Archimate::ARCHIMATE_VERSIONS)

      attribute :namespaces, Strict::Hash.default({})
      attribute :schema_locations, Strict::Array.member(Strict::String).default([])

      def initialize(attributes)
        super
        self.in_model = self
        self.parent = nil
        rebuild_index
      end

      def with(options = {})
        super.organize
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

      def register(node, parent)
        node.in_model = self
        node.parent = parent
        @index_hash[node.id] = node
      end

      def deregister(node)
        @index_hash.delete(node.id)
      end

      def find_by_class(klass)
        @index_hash.values.select { |item| item.is_a?(klass) }
      end

      def to_s
        "#{Archimate::Color.data_model('Model')}<#{id}>[#{Archimate::Color.color(name, [:white, :underline])}]"
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

      # TODO: make these DSL like things added dynamically
      def all_properties
        @index_hash.values.each_with_object([]) do |i, a|
          a.concat(i.properties) if i.respond_to?(:properties)
        end
      end

      # TODO: refactor to use property def structure instead of separate property objects
      def property_keys
        all_properties.map(&:key).uniq
      end

      # TODO: refactor to use property def structure instead of separate property objects
      def property_def_id(key)
        "propid-#{property_keys.index(key) + 1}"
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
        result = find_by_class(DataModel::Organization).select { |f| f.items.include?(item.id) }
        # raise "Program Error! #{item.id} is located in more than one organization. #{result.map(&:to_s).inspect}\n#{item}\n" if result.size > 1
        result.empty? ? nil : result.first
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
        organization = Organization.new(id: make_unique_id, name: name, type: type, items: [], organizations: [])
        register(organization, organizations)
        organizations.push(organization)
        organization
      end

      def make_unique_id
        unique_id = random_id
        unique_id = random_id while @index_hash.key?(unique_id)
        unique_id
      end

      def referenced_identified_nodes
        super.uniq
      end

      def identified_nodes
        @index_hash.values.select { |node| node.is_a? Referenceable }
      end

      def unreferenced_nodes
        identified_nodes - referenced_identified_nodes
      end

      def merge_entities(master_entity, copies)
        copies.delete(master_entity)
        copies.each do |copy|
          entities.each do |entity|
            case entity
            when entity == master_entity
              master_entity.merge(copy)
            when Organization
              entity.remove(copy.id)
            when ViewNode, Relationship, Connection
              entity.replace(copy, master_entity)
            end
          end
          deregister(copy)
        end
      end

      private

      def random_id
        @random ||= Random.new
        format("%08x", @random.rand(0xffffffff))
      end
    end
  end
end
