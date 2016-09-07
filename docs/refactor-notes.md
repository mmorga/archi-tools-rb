# Access to stuff in Archi/ArchiMate

## document.rb

element_type_names (in the document)
elements (all elements)
elements_with_type
elements_with_attribute_value
element_by_identifier
element_identifier
element_label
element_type
layer

## cleanup.rb

.css FOLDER_XPATHS (business/application/technology/motivation/implementation_migration/connectors) Archi only

* RELATION_xPATHS
* list of relations
* list of diagrams
* list of ids of relations
* list of relationships in diagrams
* element by id

## mapper.rb

.css

* list of diagrams
* list of diagram folder paths
* diagrams in a folder

## merger.rb

.css

* search for potentially matching elements by optional name and optional xsi:type
* element by id

## projector.rb

.css

* property by key
* element by type and id
* work package property by key
* work package triggering and flow relationships by target
* work package assignment relationships by source and target
* all work packages
* Property named Name, UID, PredecessorLink
* All Tasks (ms project file)

## svger.rb

.css

* element > bounds
* element by id
* element content
* element > child
* element sourceConnection
* diagrams

## quads.rb

css

* documentation

## cli/diff.rb

css

* model purpose

## element.rb

css

* documentation
* property

## folder.rb

css

* documentation
* property

## model.rb

css

* model purpose
* property