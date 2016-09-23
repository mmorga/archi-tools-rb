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

# What do I want from my value objects?

1. Value Object definition
2. Object is immutable
3. Type safety (on `new`)
4. Permits copy with changes
5. Defines `hash`
6. Defines `==`
7. Immutable Collections & Lazy evaluation
8. Memoization of expensive operations (hash)

gem             | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8
=============== | = | = | = | = | = | = | = | =
Values          | X |   |   | X |   | X |   |
anima           | X | - |   | X | - | - |   | -
equalizer       |   |   |   |   | X | X |   |
dry-equalizer   |   |   |   |   | X | X |   |
memoizable      |   |   |   |   |   |   |   | X
hamster         |   |   |   |   |   |   | X |
ice_nine        |   | X |   |   |   |   |   |
adamantium      |   | - |   |   |   |   |   |
dry-types       |   |   | X |   |   |   |   |
dry-initializer | X |   | X |   |   |   |   |

So maybe:

* dry-types
* adamantium (includes memoizable & ice_nine)
* dry-equalizer or equalizer
* hamster

---

* Value objects, gems: *~[Virtus](https://github.com/solnic/virtus)~*, [Values](https://github.com/tcrayford/Values), *anima*
* Auto `def ==(other)` & `def hash`, gems: *equalizer*, *dry-equalizer*
* Support `memoization` for things like `hash`, gems: *memoizable*
* Collections should be immutable, gems: *hamster*
* deep freezing, gems: *ice_nine*, *adamantium*
* type safety/validation: *~Virtus~*, *dry-types*
* defaults, params, gems: *dry-initializer*

Extras:

* Pattern matching and monads: *dry-matcher*, *dry-monads*, [Maybe](https://github.com/bhb/maybe)
* Auto `def dup` - well maybe - if everything is immutable, then it's not really necessary

## anima gem

Dependencies:

* abstract_type
* adamantium
    - ice_nine
    - memoizable
        + thread_safe
* equalizer

Drawbacks:

* No way to specify defaults or type safety on params

## Questions

* Value in implementing Comparable? (maybe order in original file?)

## No longer considering gems:

* ~Virtus~ - not supported by author
