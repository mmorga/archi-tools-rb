# frozen_string_literal: true
module Archimate
  module Model
    class Element
      attr_accessor :identifier, :type, :label, :documentation, :properties

      alias name label

      def initialize(identifier = "", label = "", type = "", documentation = [], properties = [])
        @identifier = identifier
        @label = label
        @type = type
        @documentation = documentation
        @properties = properties
        yield self if block_given?
      end

      def ==(other)
        @identifier == other.identifier &&
          @label == other.label &&
          @type == other.type &&
          @documentation == other.documentation &&
          @properties == other.properties
      end

      def layer
        case @type
        when "archimate:BusinessActor", "archimate:BusinessCollaboration",
             "archimate:BusinessEvent", "archimate:BusinessFunction",
             "archimate:BusinessInteraction", "archimate:BusinessInterface",
             "archimate:BusinessObject", "archimate:BusinessProcess",
             "archimate:BusinessRole", "archimate:BusinessService",
             "archimate:Contract", "archimate:Location",
             "archimate:Meaning", "archimate:Value",
             "archimate:Product", "archimate:Representation"
          then "Business"
        when "archimate:ApplicationCollaboration", "archimate:ApplicationComponent",
             "archimate:ApplicationFunction", "archimate:ApplicationInteraction",
             "archimate:ApplicationInterface", "archimate:ApplicationService",
             "archimate:DataObject"
          then "Application"
        when "archimate:Artifact", "archimate:CommunicationPath",
             "archimate:Device", "archimate:InfrastructureFunction",
             "archimate:InfrastructureInterface", "archimate:InfrastructureService",
             "archimate:Network", "archimate:Node", "archimate:SystemSoftware"
          then "Technology"
        when "archimate:Assessment", "archimate:Constraint", "archimate:Driver",
             "archimate:Goal", "archimate:Principle", "archimate:Requirement",
             "archimate:Stakeholder"
          then "Motivation"
        when "archimate:Deliverable", "archimate:Gap", "archimate:Plateau",
             "archimate:WorkPackage"
          then "Implementation and Migration"
        when "archimate:AndJunction", "archimate:Junction", "archimate:OrJunction"
          then "Connectors"
        else
          "None"
        end
      end
    end
  end
end
