# Classic SAP Gateway vs Modern SAP Service Model

Architectural orientation, so it is clear what this repository covers and what it
deliberately does not. This is **not** a migration guide.

## Why this repository intentionally focuses on Gateway / OData V2

GWGuide documents **SEGW-based SAP Gateway services** — the `MPC_EXT` / `DPC_EXT` service
model that serves OData V2. That is a deliberate scope, not an oversight.

A very large number of SAP Fiori applications running in productive on-premise landscapes
today are backed by OData V2 services built in SEGW — both SAP-delivered services and custom
ones. Those services are maintained, extended and debugged continuously: filters get pushed
down, deep entities get new children, streams get new document types, error handling gets
fixed, system aliases get repointed after a landscape change.

The skills that work requires are specific and are not covered by material about newer service
models: knowing that sorting after paging gives you a page-local order, that
`et_expanded_tech_clauses` is what stops the framework re-resolving an `$expand`, that
`get_converted_keys( )` and `get_keys( )` differ by a conversion exit, that a remote
`CALL FUNCTION ... DESTINATION` runs in its own LUW.

This repository is a working reference for exactly that. It documents the classic model
accurately rather than treating it as a stepping stone to something else.

## Classic Gateway model

What this repository covers.

| Artefact | Role |
|---|---|
| **SEGW** (Service Builder) | Models the service: entity types, entity sets, associations, complex types, function imports. Generates the runtime classes. |
| **MPC** / **MPC_EXT** | Model Provider. `MPC` is generated and regenerated; `MPC_EXT` is where you add annotations in `DEFINE` — labels, semantics, filter/sort flags, value help, media flags, tree annotations. |
| **DPC** / **DPC_EXT** | Data Provider. `DPC_EXT` is where you implement the runtime: `GET_ENTITY(SET)`, `CREATE` / `UPDATE` / `DELETE`, `CREATE_DEEP_ENTITY`, `GET_EXPANDED_ENTITY(SET)`, `EXECUTE_ACTION`, `GET_STREAM` / `CREATE_STREAM`. |
| **OData V2** | The protocol. `$filter`, `$orderby`, `$top`/`$skip`, `$expand`, `$inlinecount=allpages`, `$count`, `$value`, `$metadata`, `$batch`. |
| **Function imports** | The V2 mechanism for operations that are not CRUDQ. Modelled for `GET` or `POST`; handled in `EXECUTE_ACTION`. |
| **Deep entities** | Composite create and read in one request, via nested ABAP structures whose component names match the navigation properties. |
| **Media entities** | Entity types flagged as media, giving a `$value` endpoint for binary content. |
| **System aliases** | Configuration in `/IWFND/MAINT_SERVICE` that routes a service from the Gateway hub to a backend, resolved at runtime to an RFC destination. |
| **Hub vs embedded deployment** | Whether the Gateway frontend server and the backend are separate systems or the same one. Decides whether calls are remote or local — and therefore who owns the transaction. |
| **`/IWFND/*` and `/IWBEP/*`** | Frontend-server and backend runtime. `/IWFND/MAINT_SERVICE`, `/IWFND/GW_CLIENT`, `/IWFND/ERROR_LOG`, `/IWBEP/ERROR_LOG`. |

## Modern service-model context

Orientation only — none of this is covered by this repository.

SAP's model for **new** service development on current ABAP stacks is built on CDS and the
**ABAP RESTful Application Programming Model (RAP)**. The artefacts are different in kind, not
just in name:

| Classic Gateway | Modern service model |
|---|---|
| SEGW project | CDS data model + behaviour definition |
| `MPC_EXT` `DEFINE` annotations | CDS annotations (`@UI`, `@Search`, `@ObjectModel`, …) |
| `DPC_EXT` method implementations | Behaviour definition + behaviour implementation class |
| Service activation in `/IWFND/MAINT_SERVICE` | **Service definition** + **service binding** |
| OData V2 | OData V4 (V2 bindings also exist) |
| Function import | RAP action / function |
| Deep entity | Composition |

Two things worth stating plainly:

- These are **different service models**, not different syntax for the same thing. Concepts do
  not map one-to-one, and a service is built in one model or the other.
- Choosing between them is a **platform and landscape** decision — which release, which stack,
  which application — not a matter of one being universally correct.

This repository makes **no lifecycle or deprecation claim** about SEGW or OData V2 in either
direction. Any such claim belongs to SAP's own documentation for a specific release, and
should be read there rather than inferred from a community repository.

## Scope boundary

**In scope for GWGuide:** classic SAP Gateway. SEGW, `MPC_EXT`, `DPC_EXT`, OData V2, deep
entities, media streams, function imports, RFC destination and system-alias handling, Gateway
message and error handling, `$batch`.

**Out of scope for GWGuide:** RAP source code, behaviour definitions, service definitions and
bindings, CDS modelling, OData V4 request syntax, and migration paths between the two models.
Modern service implementation belongs in its own repository, with its own examples.

Keeping the boundary sharp is the point. A reference that tried to cover both would be a worse
reference for either, and mixing V4 syntax or RAP terminology into V2 examples is a reliable
way to produce code that does not work.

The value of this repository is **productive-landscape Gateway expertise** — the ability to
work confidently inside the service model that a great deal of running SAP Fiori estate is
actually built on.
