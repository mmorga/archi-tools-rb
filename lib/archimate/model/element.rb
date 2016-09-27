# frozen_string_literal: true
module Archimate
  module Model
    class Element < Dry::Struct::Value
      attribute :id, Archimate::Types::Strict::String
      attribute :type, Archimate::Types::Strict::String.optional
      attribute :label, Archimate::Types::Strict::String.optional
      attribute :documentation, Archimate::Types::Coercible::Array
      attribute :properties, Archimate::Types::Coercible::Array

      alias name label

      def self.create(options = {})
        new_opts = {
          type: nil,
          label: nil,
          documentation: [],
          properties: []
        }.merge(options)
        Element.new(new_opts)
      end

      def with(options = {})
        Element.new(to_h.merge(options))
      end

      def to_s
        "#{type}<#{id}> #{label} docs[#{documentation.size}] props[#{properties.size}]"
      end

      def short_desc
        "#{type}<#{id}> #{label}"
      end

      def to_id_string
        "#{type}<#{id}>"
      end

      def layer
        Archimate::Constants::ELEMENT_LAYER.fetch(@type, "None")
        # case @type
        # when "archimate:BusinessActor", "archimate:BusinessCollaboration",
        #      "archimate:BusinessEvent", "archimate:BusinessFunction",
        #      "archimate:BusinessInteraction", "archimate:BusinessInterface",
        #      "archimate:BusinessObject", "archimate:BusinessProcess",
        #      "archimate:BusinessRole", "archimate:BusinessService",
        #      "archimate:Contract", "archimate:Location",
        #      "archimate:Meaning", "archimate:Value",
        #      "archimate:Product", "archimate:Representation"
        #   then "Business"
        # when "archimate:ApplicationCollaboration", "archimate:ApplicationComponent",
        #      "archimate:ApplicationFunction", "archimate:ApplicationInteraction",
        #      "archimate:ApplicationInterface", "archimate:ApplicationService",
        #      "archimate:DataObject"
        #   then "Application"
        # when "archimate:Artifact", "archimate:CommunicationPath",
        #      "archimate:Device", "archimate:InfrastructureFunction",
        #      "archimate:InfrastructureInterface", "archimate:InfrastructureService",
        #      "archimate:Network", "archimate:Node", "archimate:SystemSoftware"
        #   then "Technology"
        # when "archimate:Assessment", "archimate:Constraint", "archimate:Driver",
        #      "archimate:Goal", "archimate:Principle", "archimate:Requirement",
        #      "archimate:Stakeholder"
        #   then "Motivation"
        # when "archimate:Deliverable", "archimate:Gap", "archimate:Plateau",
        #      "archimate:WorkPackage"
        #   then "Implementation and Migration"
        # when "archimate:AndJunction", "archimate:Junction", "archimate:OrJunction"
        #   then "Connectors"
        # else
        #   "None"
        # end
      end
    end
  end
end
