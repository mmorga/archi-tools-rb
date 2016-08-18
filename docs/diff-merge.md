# 3-Way Merge Cases

REMOTE    | BASE     | LOCAL    | Result
--------- | -------- | -------- | --------
add       | np       | np       | use REMOTE
np        | np       | add      | use LOCAL
change    | p        | p        | use REMOTE
remove    | p        | p        | use REMOTE (unless LOCAL adds dependency)
change    | p        | change   | conflict (can make this more granular by applying change down to attribute and children level)
remove    | p        | pc       | use LOCAL

---

## Document of documents

Re-thinking how to diff for tree structured documents (xml/json)

Traditional diff operates by text lines with no conception of structure besides line. This makes for a messy diff on structed documents which aren't necessarily line oriented.

There is an order that diffs are oriented - which is line order.

In XML, element order is significant, so you could think of each element the way a diff approaches a line, but there is more to it...

In XML, attribute order is insignificant, so each attribute could be considered a "line" but there is no specific order here, so maybe for diff purposes sort attributes by name then compare.

Then there's children ... each set of children within an XML element could be considered a new document for comparison with a matching element children. Each child of which is both a line in the parent's document and a document itself.

Aside: Would regular diffs on XML work if the compared documents were first strictly formatted like this?:

```xml
<doc id="132"
    a="31"
    b="somethign"
    >
    <child1 id="342"
        d="dee"
        />
    <child2/>
</doc>
```

## XML Document Type for significant comparisons

In Archi's `.archimate` format there's a certain number of entities that are significant from the consumer's standpoint...

* Model
    - root element: `<archimate:model/>`
    - id: `@id`
    - name: `@name`
    - documentation: `purpose`*
    - properties: `property`*
* Entity (and Connectors)
    - root element: `<element/>`
    - id: `@id`
    - name: `@name`
    - type: `@xsi:type`
    - documentation: `documentation`*
    - properties: `property`*
* Relations
    - root element: `<element/>`
    - id: `@id`
    - name: `@name`
    - type: `@xsi:type`
    - source: `@source`?
    - target: `@target`?
    - documentation: `documentation`*
    - properties: `property`*
* Diagrams
    - root element: `<element xsi:type="archimate:ArchimateDiagramModel|archimate:SketchModel"/>`
    - id: `@id`
    - name `@name`
    - type: `@xsi:type`
    - viewpoint `@viewpoint`?
* Organization (Folders)
    - root element: `<folder`
    - id: `@id`
    - name: `@name`
    - type: `@type`?
    - note: I'm only going to care about these under diagrams


## Merge Rules

* One of two docs is considered the parent - ids will default there
* First checks for unique ids are made. Re-mapping will be done if necessary. More on remapping rules below.

