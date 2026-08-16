# SEGW Data Model — Entity Types, Complex Types, Function Imports and Media

Reference for the modelling artefacts created in the **Service Builder (`SEGW`)** Data Model
tree, and how each one surfaces in the generated `MPC` / `MPC_EXT` and is consumed in
`DPC_EXT`.

All names below are generic placeholders. Adapt them to your own service.

## Where this lives in SEGW

```
SEGW
└── <PROJECT>                       e.g. ZSM_EXAMPLE
    └── Data Model
        ├── Entity Types            structure + properties + key
        ├── Associations            relationship between two entity types
        ├── Entity Sets             the addressable collection of an entity type
        ├── Association Sets        the addressable form of an association
        ├── Function Imports        non-CRUD operations
        └── Complex Types           reusable structured property groups
    └── Service Implementation      maps entity sets to DPC methods
    └── Runtime Artifacts           MPC, MPC_EXT, DPC, DPC_EXT
    └── Service Maintenance         registration per system
```

After modelling, **Generate Runtime Objects** creates the four runtime classes. You implement
in `MPC_EXT` and `DPC_EXT`; the plain `MPC` / `DPC` are regenerated and must not be edited.

## Entity Types and Entity Sets

An **entity type** is the structure. An **entity set** is the addressable collection.

| Column in SEGW | Meaning |
|---|---|
| `Name` | External (OData) property name, e.g. `DocumentId` |
| `Is Key` | Part of the entity key — mandatory for at least one property |
| `Edm Core Type` | `Edm.String`, `Edm.DateTime`, `Edm.Time`, `Edm.Decimal`, `Edm.Boolean`, `Edm.Guid`, … |
| `Precision` / `Scale` | Required for `Edm.DateTime` (7) and `Edm.Decimal` |
| `Max Length` | Length for `Edm.String` |
| `Creatable` / `Updatable` / `Sortable` / `Nullable` / `Filterable` | Metadata flags — see the warning below |
| `Unit Property Name` | Points at the currency/UoM property |
| `Label` | Text shown by a Fiori UI (`sap:label`) |
| `ABAP Field Name` | The field in the underlying ABAP structure |
| `Semantics` | `sap:semantics` — e.g. `email`, `tel`, `currency-code` |

Example entity type `Document` (media, see below):

| Name | Key | Edm Core Type | Max | ABAP Field Name |
|---|---|---|---|---|
| `DocumentId` | ✔ | `Edm.String` | 32 | `DOCUMENT_ID` |
| `FileName` | | `Edm.String` | 128 | `FILE_NAME` |
| `MimeType` | | `Edm.String` | 127 | `MIME_TYPE` |
| `CreatedOn` | | `Edm.DateTime` (Prec. 7) | | `CREATED_ON` |
| `CreatedAt` | | `Edm.Time` | | `CREATED_AT` |
| `CreatedBy` | | `Edm.String` | 12 | `CREATED_BY` |
| `Url` | | `Edm.String` | 255 | `URL` |

> **The `Creatable` / `Updatable` / `Deletable` flags are metadata, not security.**
> They shape the `$metadata` document and what a Fiori UI renders. They do **not** prevent a
> direct HTTP request. Business authorization must be enforced in `DPC_EXT` or in the
> BAPI/function module it calls. See the root README, *Security & Authorization Boundary*.

Property flags are set in `MPC_EXT` with `set_filterable( )`, `set_sortable( )`,
`set_updatable( )`; entity-set-level flags with `set_creatable( )`, `set_deletable( )`,
`set_pageable( )`, `set_addressable( )` on `/IWBEP/IF_MGW_ODATA_ENTITY_SET`.

## Associations, Navigation Properties and Association Sets

An **association** relates two entity types with a cardinality (`1..1`, `1..n`, `0..n`) and a
**referential constraint** mapping the principal key to the dependent field.

Modelling an association generates a **navigation property** on the entity type. That name is
what a client uses:

```
GET /sap/opu/odata/sap/ZSM_SRV/HeaderSet('0000000001')/HeaderToItemNav
GET /sap/opu/odata/sap/ZSM_SRV/HeaderSet('0000000001')?$expand=HeaderToItemNav
```

The first form navigates; the second expands. On the ABAP side the first is served by the
navigation-aware `GET_ENTITYSET` (via `it_navigation_path` / `iv_source_name`), the second by
`GET_EXPANDED_ENTITY(SET)`.

**Naming rule that trips people up:** for `CREATE_DEEP_ENTITY` and `GET_EXPANDED_ENTITY(SET)`,
the nested component names of your deep ABAP structure must line up with the navigation
properties, and the technical component names are what you report in
`et_expanded_tech_clauses`. See [`../MPC_EXT/TYPES/Types.abap`](../MPC_EXT/TYPES/Types.abap)
and [`../DPC_EXT/METHODS/GetExpandedEntitySet.abap`](../DPC_EXT/METHODS/GetExpandedEntitySet.abap).

## Complex Types

A **complex type** is a reusable group of properties with no key. It cannot be addressed on
its own — it appears as a structured property of an entity type, or as the return type of a
function import.

Example complex type `PlanningWindow`:

| Name | Edm Core Type | Prec. | ABAP Field Name |
|---|---|---|---|
| `LineNo` | `Edm.String` | | `LINE_NO` |
| `PartnerName` | `Edm.String` | | `PARTNER_NAME` |
| `PlanStartTime` | `Edm.Time` | | `PLAN_START_TIME` |
| `PlanStartDate` | `Edm.DateTime` | 7 | `PLAN_START_DATE` |

In ABAP this maps to a flat structure included in the entity type's structure, or used
standalone as a function import's return type.

## Function Imports

A **function import** is the OData V2 mechanism for an operation that does not fit CRUDQ.
It is modelled under *Function Imports* and implemented in
`/IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION`.

| Column in SEGW | Meaning |
|---|---|
| `Name` | Function import name — the URI segment |
| `Return Type Kind` | `Complex Type`, `Entity Type`, or none |
| `Return Type` | The complex/entity type returned |
| `Return Cardinality` | `1` for a single instance, `n` for a collection |
| `Return Entity Set` | Required when returning an entity type |
| `HTTP Method Type` | `GET` or `POST` |
| `Action for Entity Type` | Optional binding to an entity type |

Example:

| Name | Return Type Kind | Return Type | Cardinality | HTTP Method |
|---|---|---|---|---|
| `GetPlanningWindow` | Complex Type | `PlanningWindow` | 1 | `GET` |
| `ReleaseDocument` | Complex Type | `ActionResult` | 1 | `POST` |

**Choose the HTTP method by what the operation does:**

- **`GET`** — read-only, safe and idempotent. Safe to prefetch or cache.
- **`POST`** — anything that changes business state. `GET` is defined as safe, so a
  state-changing `GET` may be triggered by a prefetch, a proxy or a link — and in SAP Gateway
  it also bypasses CSRF token enforcement, which only applies to modifying HTTP methods.

Parameters are modelled beneath the function import:

| Name | EDM Core Type | ABAP Field Name |
|---|---|---|
| `DocumentId` | `Edm.String` | `DOCUMENT_ID` |
| `PartnerName` | `Edm.String` | `PARTNER_NAME` |

Called as:

```
GET  /sap/opu/odata/sap/ZSM_SRV/GetPlanningWindow?DocumentId='0000000001'&PartnerName='EXAMPLE'
POST /sap/opu/odata/sap/ZSM_SRV/ReleaseDocument?DocumentId='0000000001'
```

Implementation: [`../DPC_EXT/METHODS/ExecuteAction.abap`](../DPC_EXT/METHODS/ExecuteAction.abap).
Model-side annotations: [`../MPC_EXT/METHODS/Define.abap`](../MPC_EXT/METHODS/Define.abap).

## Media resources (streams)

An entity type flagged as **media** gains a `$value` endpoint carrying binary content, which
is how attachments and documents are served.

Model it in the SEGW entity type (the `Media` checkbox on the entity type list) or in
`MPC_EXT`:

```abap
lo_entity = model->get_entity_type( iv_entity_name = 'Document' ).
lo_entity->set_is_media( iv_is_media = abap_true ).
lo_entity->get_property( iv_property_name = 'MimeType' )->set_as_content_type( ).
```

That pairing is what makes the entity a media resource and routes requests to the stream
methods:

| Request | DPC_EXT method |
|---|---|
| `GET  .../DocumentSet('0000000001')/$value` | `~GET_STREAM` |
| `POST .../DocumentSet` with a binary body and a `Slug` header | `~CREATE_STREAM` |
| `PUT  .../DocumentSet('0000000001')/$value` | `~UPDATE_STREAM` |

The property flagged with `set_as_content_type( )` supplies the `Content-Type` of the
returned stream.

Implementations: [`../DPC_EXT/METHODS/GetStream.abap`](../DPC_EXT/METHODS/GetStream.abap),
[`../DPC_EXT/METHODS/CreateStream.abap`](../DPC_EXT/METHODS/CreateStream.abap),
[`../DPC_EXT/METHODS/DocumentGetEntitySet.abap`](../DPC_EXT/METHODS/DocumentGetEntitySet.abap).

## Checking the result

The generated model is visible as the service metadata document:

```
GET /sap/opu/odata/sap/ZSM_SRV/$metadata
```

Everything modelled here — entity types, keys, complex types, associations, navigation
properties, function imports, media flags and `sap:` annotations — appears there. When a
value help or a label does not show up in a Fiori app, `$metadata` is the first place to look.
