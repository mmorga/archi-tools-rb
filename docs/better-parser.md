`bin/archimate convert -t meff2.1 -o rax.xml examples/Rackspace.archimate`

## Original conversion operation:

273.49s user 4.26s system 99% cpu 4:39.49 total

## With Ox::Builder as writer

260.74s user 3.33s system 99% cpu 4:26.40 total

# Archi File map

* archimate:model
    - folder type="business|application|technology|motivation|implementation_migration|connectors|relations|derived"
        + documentation
        + folder
        + element
    - folder type="diagrams"
        + folder
        + element xsi:type="archimate:ArchimateDiagramModel"
            * child
                - bounds
                - sourceConnection
                    + bendpoint
                - child

# MEFF File map

* model
    - name
    - elements
        + element
            * label
    - relationships
        + relationship
    - organization
        + item
            * label
            * documentation
            * item(identifierref)
            * item
    - propertydefs
        + propertydef
    - views
        + view
            * label
            * node
                - label
                - style
                    + fillColor
                    + lineColor
                - node
            * connection
                - style
                - bendpoint


---

In: Archi:

```xml
<archimate:model
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:archimate="http://www.archimatetool.com/archimate"
    name="Rackspace"
    id="bee5a0a7"
    version="3.1.1">
```

Out: MEFF:

```xml
<model
  xmlns="http://www.opengroup.org/xsd/archimate"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  identifier="id-bee5a0a7"
  xsi:schemaLocation="http://www.opengroup.org/xsd/archimate http://www.opengroup.org/xsd/archimate/archimate_v2p1.xsd">
  <name xml:lang="en">Rackspace</name>
```

---

In: <folder>

inside: <organization>

Out:

```xml
<item>
      <label xml:lang="en">Business</label>
      <documentation xml:lang="en">The Business Layer offers products and ...</documentation>
```

item contains all elements in the folder as

```xml
      <item identifierref="id-0f6c2750"/>
```

Folder id is lost

---
---

model

* metadata (no match in Archi format)
* name -> archimate:model(name)
* documentation -> archimate:model()[purpose]
* properties -> archimate:model()[property] xformed to:
    - property(identifierref="{propid}")[value(xml:lang="")[{val}]]
* elements -> all element except relations and diagrams
    - element(identifier="id-{id}" xsi:type="")
        + label(xml:lang="")[label]
        + documentation(xml:lang="")[]
        + properties
* relationships -> all element one of relation types
    - relationship(identifier="id-{id}" source="" target="" xsi:type="")
        + label(xml:lang="")[label]
        + documentation(xml:lang="")[]
        + properties
* organization -> all folders xformed as above
    - item(identifier="")
        + label
        + documentation
        + item*
* propertydefs -> all property collated by key and id created by order occurred in document
    - propertydef(identifier name type)*
        + type can be one of:
            * "string"
            * "boolean"
            * "currency"
            * "date"
            * "time"
            * "number"
* views -> all element of type "archimate:ArchimateDiagramModel"
    - view(identifier, viewpoint)
        + label
        + documentation
        + properties
        + node(identifier elementref x y w h type)*
            * label
            * documentation
            * properties
            * style(lineWidth?)
                - fillColor(r g b a)
                - lineColor(r g b a)
                - fontType(name style size)
                    + color(r g b a)
            * node*
        + connection*
    - viewpoint can be:
            * Introductory
            * Organization
            * Actor Co-operation
            * Business Function
            * Business Process
            * Business Process Co-operation
            * Product
            * Application Behavior
            * Application Co-operation
            * Application Structure
            * Application Usage
            * Infrastructure
            * Infrastructure Usage
            * Implementation and Deployment
            * Information Structure
            * Service Realization
            * Layered
            * Landscape Map
            * Stakeholder
            * Goal Realization
            * Goal Contribution
            * Principles
            * Requirements Realization
            * Motivation
            * Project
            * Migration
            * Implementation and Migration


# Timings

nokogiri loading rackspace.archimate

objectspace count (before): 42166
objectspace count (after): 281952

after GC start, 39341

{:TOTAL=>319967,
 :FREE=>3653,
 :T_OBJECT=>14539,
 :T_CLASS=>2172,
 :T_MODULE=>154,
 :T_FLOAT=>6,
 :T_STRING=>151188,
 :T_REGEXP=>1005,
 :T_ARRAY=>63306,
 :T_HASH=>49807,
 :T_STRUCT=>224,
 :T_BIGNUM=>2,
 :T_FILE=>5,
 :T_DATA=>10820,
 :T_MATCH=>168,
 :T_COMPLEX=>1,
 :T_RATIONAL=>1,
 :T_SYMBOL=>138,
 :T_IMEMO=>22446,
 :T_NODE=>99,
 :T_ICLASS=>233}
