# TODO

* [ ] Implement check for de-duplicated merges
* [ ] Improve description of diffs for conflict display
* [ ] Convert all CLIs to use AIO
* [ ] Eliminate use of Document in favor of Model
  - [ ] cli/archi.rb
  - [ ] cli/cleanup.rb
  - [ ] cli/convert.rb
  - [ ] cli/svger.rb
* [ ] See what can be done about performance
  - Reading file 11-12 secs
  - deleted relationships referenced in diagrams is slow
* [ ] Clean up TODOs
* [ ] Refactor to better OO design where necessary (see all about names below)
* Convert support for
  - [ ] Rdf
  - [ ] Gremlin
  - [X] N-Quad
  - [X] GraphML
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

