# TODO

* [x] Not handling sketch diagram model in archi
* [ ] Archi file could have ids that conflict (i.e. 2 relationships with same id - this is bad!!! Was it a bad merge or something worse)
* [ ] make classes for each element and relationship type
* [ ] figure out a better parent mechanism - it's really not fully cooked
* [ ] remove parent_id from dry::struct objects - then can use class schema instead of comparison attributes
* [ ] Figure out how to make rmagick optional and/or remove rmagick dependency
* [ ] Decide between ox and nokogiri and eliminate the alternate
* [X] Use one color method - currently using HighLine and Colorize
* [x] Refactor merge to pull conflict detection out
* [ ] Refactor merge to pull apply diffs out
* [X] Clean up the way that the describe is done on data model
* [X] Permit model items to link back to their parent
* [ ] Data model items that reference something else by id should have the actual object available - not just the id
* [X] Should be a master hash index of id to object in Model
* [ ] Implement check for de-duplicated merges
* [X] Improve description of diffs for conflict display
* [ ] Convert all CLIs to use AIO
* [ ] Eliminate use of Document in favor of Model
  - [ ] cli/archi.rb
  - [ ] cli/cleanup.rb
  - [ ] cli/convert.rb
  - [X] cli/svger.rb
* [ ] See what can be done about performance
  - Reading file 11-12 secs
  - deleted relationships referenced in diagrams is slow
* [ ] Refactor to better OO design where necessary (see all about names below)
* Convert support for
  - [ ] Rdf
  - [ ] Gremlin
  - [X] N-Quad
  - [X] GraphML
* [X] Clean up TODOs
* [x] Experiment with Ox, Oga, Sax-Machine for better performance on convert
* [x] Map conversion between archi and archimate diagram formats

## Other tool ideas

* Tool to query for dependencies
* Tool to assign/validate/enforce metadata

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

