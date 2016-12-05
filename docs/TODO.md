# TODO

* [ ] Add Split file feature
* [ ] Merge unrelated files (this is the intent of Merger)
* [ ] Stats (elements, relationships, diagrams)
* [ ] Scorecard lint
* [ ] CLI DSL
* [ ] Add a super strict mode to note when reader finds unexpected content
* [ ] Consider breaking this into a number of gems (for example: base lib, diff/merge, other cmdline tools)
* [ ] Archi file could have ids that conflict (i.e. 2 relationships with same id - this is bad!!! Was it a bad merge or something worse)
* [ ] make classes for each element and relationship type?
* [ ] Convert all CLIs to use AIO - merge with OutputIO and MaybeIO (maybe)
* [ ] Figure out how to make rmagick optional and/or remove rmagick dependency
* [ ] Data model items that reference something else by id should have the actual object available - not just the id
* [ ] Implement check for de-duplicated merges
* Convert support for
  - [ ] Neo4j CSV
  - [ ] Rdf
  - [ ] Gremlin
  - [X] N-Quad
  - [X] GraphML
* [X] figure out a better parent mechanism - it's really not fully cooked
* [X] remove parent_id from dry::struct objects - then can use class schema instead of comparison attributes
* [x] Not handling sketch diagram model in archi
* [X] Use one color method - currently using HighLine and Colorize
* [x] Refactor merge to pull conflict detection out
* [X] Clean up the way that the describe is done on data model
* [X] Permit model items to link back to their parent
* [X] Should be a master hash index of id to object in Model
* [X] Improve description of diffs for conflict display
* [X] Eliminate use of Document in favor of Model
  - [X] cli/archi.rb
  - [X] cli/cleanup.rb
  - [X] cli/convert.rb
  - [X] cli/svger.rb
* [X] Clean up TODOs
* [x] Experiment with Ox, Oga, Sax-Machine for better performance on convert
* [x] Map conversion between archi and archimate diagram formats
* [X] Write a common clone for dry-struct classes
* [X] Make a format agnostic file reader (which delegates to appropriate file type readers)
* [X] Decide between ox and nokogiri and eliminate the alternate
* [X] See what can be done about performance
  - Reading file 11-12 secs
  - deleted relationships referenced in diagrams is slow
* [X] Refactor to better OO design where necessary (see all about names below)
* [X] Refactor merge to pull apply diffs out

## Other tool ideas

* Tool to query for dependencies
* Tool to assign/validate/enforce metadata

## My Classes

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

---

# DSL additions

# type                        from               to
"AssociationRelationship",    "associated_with", "associated_with"
"AccessRelationship",         "accesses",        "accessed_by"
"UsedByRelationship",         "used_by",         "uses"
"RealisationRelationship",    "realizes",        "realized_by"
"AssignmentRelationship",     ""
"AggregationRelationship"
"CompositionRelationship"
"FlowRelationship"
"TriggeringRelationship"
"GroupingRelationship"
"SpecialisationRelationship"
"InfluenceRelationship"

