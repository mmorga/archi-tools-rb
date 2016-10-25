# TODO

* [ ] Monkey patch nokogiri with methods to support archi/archimate format with common methods so you can work without conversion.
* [ ] Convert support for
  - [ ] Rdf
  - [ ] Gremlin
  - [X] N-Quad
  - [X] GraphML
* [ ] Experiment with Ox, Oga, Sax-Machine for better performance on convert
* Map conversion between archi and archimate diagram formats

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

## Eliminate use of Document in favor of Model

[ ] cli/archi.rb
[ ] cli/cleanup.rb
[ ] cli/convert.rb
[ ] cli/svger.rb

## Standardize the io for cli classes

Should have:

* Input (How to deal with CLIs that require multiple inputs?)
* Output - for results (Multiple Outputs - like Cleanup?)
* Error Messages
* Interactive (IO for messages and questions)
* Support for progress bars

and should encapsulate things like `force`, `verbose`, etc.

## Performance

Reading file 11-12 secs
Diff computation is fast

deleted relationships referenced in diagrams is slow

apply diffs is too slow - problem is likely in the ice_nine deep freeze

---

# All about names

Merge in an OO way.

Load the candidate documents which could be different type/version files into standard model

```ruby
base = LoadDocument.load("base.archimate")
local = LoadDocument.load("local.archimate")
remote = LoadDocument.load("remote.archimate")

merged_document, conflicts = base.merge(local, remote) # three way merge?
```

Merger might be the right name for the object?

```ruby
patch_set, unresolved_conflicts = conflicts.resolve(review)
```

# My Classes

* Conflict
* Conflicts
  - `#resolve : Review -> (PatchSet, Conflicts)`
* Difference
* Document
  - `#merge : ~local:Document -> ~remote:Document -> (Document, Conflicts)`
  - `#patch : PatchSet -> Document`
* PatchSet
* Review
  - `#resolve : Conflict -> Difference`

