# De-duplication Notes

## Duplicate Detection

Current element types can be found with this xpath query in the `archimate_v2p1.xsd` schema:

```xpath
/xs:schema//xs:complexType[xs:complexContent[xs:extension[@base="elementType"]]]/@name
```

For example: find dupes of `element`s of type `BusinessObject` with name `Firewall`.

```xpath
//default:element[@xsi:type="BusinessObject" and default:label="Firewall"]
```

or just the identifiers of the duplicates:

```xpath
//default:element[@xsi:type="BusinessObject" and default:label="Firewall"]/@identifier
```

Select all elements with an attribute that matches an id:

```xpath
/default:model//*[@*="id-233b156d"]
```

1. For each `element` by `xsi:type` attribute
2. If names match (see matching options), candidate for merge
3. Ask to merge, if yes, run merge process

## Merge Process

Pick the 1st one to be the *original* the other(s) to be *copies*.

Other thoughts:

1. Handle placing the merged element at a particular point in the folder tree.

Process:

1. Determine which one is the *original*
2. Copy any attributes/docs, etc. from each of the others into the original.
    1. Child `label`s with different `xml:lang` attribute values
    2. Child `documentation` (and different `xml:lang` attribute values)
    3. Child `properties`
    4. Any other elements
3. Delete the copy element from the document
4. For each copy, change references from copy id to original id
    1. `relationship`: `source` & `target` attributes
    2. `property`: `identifierref` attribute
    3. `item`: `identifierref` attribute
    4. `node`: `elementref` attribute
    5. `connection`: `relationshipref`, `source`, `target` attributes

