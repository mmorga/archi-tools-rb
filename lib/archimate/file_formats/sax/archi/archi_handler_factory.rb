# frozen_string_literal: true

module Archimate
  module FileFormats
    module Sax
      module Archi
        class ArchiHandlerFactory
          def handler_for(name, attrs)
            case name
            when "model", "archimate:model"
              Model
            when "documentation", "purpose"
              Sax::PreservedLangString
            when "element"
              element_type = Hash[attrs]["xsi:type"].sub(/archimate:/, '')
              case element_type
              when DataModel::ElementType, DataModel::ConnectorType
                Element
              when DataModel::DiagramType
                Diagram
              when DataModel::RelationshipType
                Relationship
              else
                raise "Unexpected element_type #{element_type}"
              end
            when "property"
              Property
            when "folder"
              Organization
            when "child"
              ViewNode
            when "bounds"
              Bounds
            when "sourceConnection"
              Connection
            when "bendpoint"
              Location
            when "content"
              Content
            else
              raise "Unhandled element name #{name}"
            end
          end
        end
      end
    end
  end
end
