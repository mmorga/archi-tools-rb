# TODO

* [ ] Monkey patch nokogiri with methods to support archi/archimate format with common methods so you can work without conversion.
* [ ] Convert support for
  - [ ] Rdf
  - [ ] Gremlin
  - [X] N-Quad
  - [X] GraphML
* [ ] Experiment with Ox, Oga, Sax-Machine for better performance on convert

## Other tool ideas

* Tool to query for dependencies
* Tool to assign/validate/enforce metadata

## Deal with relationships

```ruby
    "archimate:AccessRelationship" => relations_folder_xpath,
    "archimate:AggregationRelationship" => relations_folder_xpath,
    "archimate:AssignmentRelationship" => relations_folder_xpath,
    "archimate:AssociationRelationship" => relations_folder_xpath,
    "archimate:CompositionRelationship" => relations_folder_xpath,
    "archimate:FlowRelationship" => relations_folder_xpath,
    "archimate:InfluenceRelationship" => relations_folder_xpath,
    "archimate:RealisationRelationship" => relations_folder_xpath,
    "archimate:SpecialisationRelationship" => relations_folder_xpath,
    "archimate:TriggeringRelationship" => relations_folder_xpath,
    "archimate:UsedByRelationship" => relations_folder_xpath,

    "archimate:SketchModel" => diagrams_folder_xpath,
    "archimate:ArchimateDiagramModel" => diagrams_folder_xpath
```
