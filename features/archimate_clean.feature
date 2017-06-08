Feature: Archimate clean model

  `archimate` models can have accumulate a bit of cruft over time. For example:

   \* Orphaned Elements - belong to no relationships and are depicted in no diagrams.
   \* Orphaned Relationships - that are depicted in no diagrams.
  
  The clean operation identifies these orphans in your model and permit you to optionally
  remove these orphans.

  Scenario: Cleaning the Archisurance example 
    When I run `bin/archimate clean /Users/mmorga/work/standards/archimate/test/examples/archisurance.archimate -o /Users/mmorga/work/standards/archimate/clean.archimate`
    Then the file "clean.archimate" should be equal to file "test/examples/archisurance.archimatebar"
