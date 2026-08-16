# GWGuide — A Practical SAP Gateway & OData V2 Engineering Reference

Working reference for building, extending and debugging **SEGW-based SAP Gateway services** —
the `MPC_EXT` / `DPC_EXT` service model behind a large share of productive SAP Fiori
applications. Patterns collected while implementing and maintaining these services in real
landscapes: CRUDQ, deep entities and `$expand`, media streams, function imports, query-option
handling, Gateway message and error handling, RFC destination resolution and value-help
integration.

## Scope

- **Classic SAP Gateway / SEGW / OData V2.** Intentionally so — see
  [Why classic Gateway?](#why-classic-gateway)
- **A reference and cookbook, not a runnable application.** Most `.abap` files are independent
  method bodies, not complete classes.
- **Examples are illustrative** and must be adapted to the artefacts your own SEGW project
  generates. `Z`/`ZSM` object names, service names and types are placeholders.
- **Not official SAP documentation.** Behaviour varies across releases and support packages —
  validate in your own system.
- **Business authorization is the consuming application's responsibility.** See
  [Security & Authorization Boundary](#security--authorization-boundary).

## Highlights

| Topic | Where |
|---|---|
| `GET_ENTITYSET` query handling — `$filter` → ranges, `$inlinecount`, `$orderby`, `$top`/`$skip`, and the order they belong in | [`DPC_EXT/METHODS/GetEntitySet.abap`](DPC_EXT/METHODS/GetEntitySet.abap) |
| The generic vs generated `GET_ENTITYSET` signature | [`DPC_EXT/METHODS/RuntimeGetEntitySet.abap`](DPC_EXT/METHODS/RuntimeGetEntitySet.abap) |
| Deep entities and `$expand` — `et_expanded_tech_clauses`, nested type contracts | [`GetExpandedEntity.abap`](DPC_EXT/METHODS/GetExpandedEntity.abap), [`GetExpandedEntitySet.abap`](DPC_EXT/METHODS/GetExpandedEntitySet.abap), [`Types.abap`](MPC_EXT/TYPES/Types.abap) |
| Composite create with a correct commit boundary | [`DPC_EXT/METHODS/CreateDeepEntity.abap`](DPC_EXT/METHODS/CreateDeepEntity.abap) |
| Media streams — `$value`, Slug handling, MIME and Content-Disposition | [`CreateStream.abap`](DPC_EXT/METHODS/CreateStream.abap), [`GetStream.abap`](DPC_EXT/METHODS/GetStream.abap) |
| Function imports (`EXECUTE_ACTION`), including `GET` vs `POST` modelling | [`DPC_EXT/METHODS/ExecuteAction.abap`](DPC_EXT/METHODS/ExecuteAction.abap) |
| `MPC_EXT` annotations — labels, semantics, filter restrictions, value help, media, tree tables | [`Define.abap`](MPC_EXT/METHODS/Define.abap), [`UtilClass.abap`](MPC_EXT/METHODS/UtilClass.abap) |
| Gateway message container and business vs technical exceptions | [`DPC_EXT/METHODS/Exception.abap`](DPC_EXT/METHODS/Exception.abap) |
| RFC destination resolution, hub vs embedded deployment | [`DESTINATION/Destination.abap`](DESTINATION/Destination.abap) |
| Search-help / value-help integration | [`ODATA/StandardSearchHelps.md`](ODATA/StandardSearchHelps.md), [`ODATA/ValueHelpSources.md`](ODATA/ValueHelpSources.md) |

## Why Classic Gateway?

SEGW / `MPC_EXT` / `DPC_EXT` / OData V2 is the service model a great deal of running SAP Fiori
estate is built on, and it is maintained and extended continuously. This repository documents
that model accurately rather than treating it as a stepping stone.

**[Classic SAP Gateway vs Modern SAP Service Model →](CLASSIC-GATEWAY-VS-MODERN-SERVICE-MODEL.md)**
explains the scope decision, orients the classic model against CDS / service definition /
service binding / RAP / OData V4, and states what deliberately belongs elsewhere. No lifecycle
or deprecation claim is made in either direction.

## Repository Structure

```
BATCH/
  README.md                  $batch multipart requests and changesets
CLASSIC-GATEWAY-VS-MODERN-SERVICE-MODEL.md
DATA_MODEL/
  README.md                  SEGW data model: entity types, complex types,
                             function imports, media resources
DESTINATION/
  Destination.abap           RFC destination / system alias resolution
DPC_EXT/
  METHODS/
    CreateDeepEntity.abap    CREATE_DEEP_ENTITY + commit boundary
    CreateEntity.abap        CREATE_ENTITY (skeleton)
    CreateStream.abap        CREATE_STREAM - media upload
    DeleteEntity.abap        DELETE_ENTITY + LUW / authorization notes
    DocumentGetEntitySet.abap  media list with $value URLs
    Exception.abap           canonical error / message handling
    ExecuteAction.abap       function imports
    GetEntity.abap           GET_ENTITY, converted vs raw keys
    GetEntitySet.abap        GET_ENTITYSET - six query patterns
    GetExpandedEntity.abap   GET_EXPANDED_ENTITY
    GetExpandedEntitySet.abap  GET_EXPANDED_ENTITYSET
    GetStream.abap           GET_STREAM - media download
    RuntimeGetEntitySet.abap generic runtime GET_ENTITYSET
    UpdateEntity.abap        UPDATE_ENTITY + local/remote LUW
MPC_EXT/
  METHODS/
    Define.abap              DEFINE annotation examples
    TextElements.png         SE80 text symbols (translatable labels)
    UtilClass.abap           ZCL_SM_MPC_UTIL annotation helper
  TYPES/
    Types.abap               deep-entity type fragments
ODATA/
  README.md                  URI anatomy + OData V2 query reference
  StandardSearchHelps.md     standard SAP search helps (SHLP)
  ValueHelpSources.md        DDIC check/text tables for value helps
SYSTEM/
  UserInfo.abap              request context, user identity
LICENSE
```

## Learning Path

| # | Topic | What you learn |
|---|---|---|
| 1 | [OData V2 reference](ODATA/README.md) | URI anatomy, query options, key and literal syntax, escaping |
| 2 | [SEGW data model](DATA_MODEL/README.md) | Entity types, associations, complex types, function imports, media |
| 3 | [Error & message handling](DPC_EXT/METHODS/Exception.abap) | Message container, business vs technical exceptions — **read this before the code that can fail** |
| 4 | [`MPC_EXT` annotations](MPC_EXT/METHODS/Define.abap) · [helper class](MPC_EXT/METHODS/UtilClass.abap) | Labels, semantics, filter/sort flags, value help, media, tree tables |
| 5 | [`GET_ENTITY`](DPC_EXT/METHODS/GetEntity.abap) | Key extraction, conversion exits, not-found behaviour |
| 6 | [`GET_ENTITYSET`](DPC_EXT/METHODS/GetEntitySet.abap) | `$filter` → ranges, and why the order filter → count → sort → page matters |
| 7 | [Generic `GET_ENTITYSET`](DPC_EXT/METHODS/RuntimeGetEntitySet.abap) | The generic runtime signature, and safe dynamic `$orderby` |
| 8 | [`CREATE`](DPC_EXT/METHODS/CreateEntity.abap) · [`UPDATE`](DPC_EXT/METHODS/UpdateEntity.abap) · [`DELETE`](DPC_EXT/METHODS/DeleteEntity.abap) | Reading the payload, propagating messages, who owns the transaction |
| 9 | [`$expand`](DPC_EXT/METHODS/GetExpandedEntity.abap) · [collections](DPC_EXT/METHODS/GetExpandedEntitySet.abap) | Resolving expands yourself and declaring `et_expanded_tech_clauses` |
| 10 | [Deep entity](DPC_EXT/METHODS/CreateDeepEntity.abap) · [types](MPC_EXT/TYPES/Types.abap) | Composite create, nested-component naming, cardinality |
| 11 | [Function imports](DPC_EXT/METHODS/ExecuteAction.abap) | `EXECUTE_ACTION`, parameter conversion, `GET` vs `POST` |
| 12 | [Media streams](DPC_EXT/METHODS/CreateStream.abap) · [download](DPC_EXT/METHODS/GetStream.abap) · [list](DPC_EXT/METHODS/DocumentGetEntitySet.abap) | `$value`, Slug as untrusted metadata, MIME and Content-Disposition |
| 13 | [Destinations](DESTINATION/Destination.abap) | System alias vs RFC destination, hub vs embedded, LUW consequences |
| 14 | [Value helps](ODATA/StandardSearchHelps.md) · [sources](ODATA/ValueHelpSources.md) | Search helps and DDIC tables behind a value help |
| 15 | [Request context](SYSTEM/UserInfo.abap) | Authenticated identity vs client-supplied request metadata |
| 16 | [`$batch`](BATCH/README.md) | Multipart requests, changesets, and changeset atomicity |

## Quick OData V2 Reference

| Purpose | Example |
|---|---|
| Entity set | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet` |
| Single entity | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')` |
| Composite key | `GET /sap/opu/odata/sap/ZSM_SRV/POItemSet(Ebeln='4500000000',Ebelp='00010')` |
| Numeric key | `GET /sap/opu/odata/sap/ZSM_SRV/ProductSet(42)` |
| GUID key | `GET /sap/opu/odata/sap/ZSM_SRV/DocumentSet(guid'005056a5-1f2e-1eda-8fb2-1a2b3c4d5e6f')` |
| `$filter` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$filter=Erdat ge datetime'2021-12-26T00:00:00'` |
| `$filter` with a quote | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$filter=Ernam eq 'O''Brien'` |
| `$orderby` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$orderby=Erdat desc` |
| `$select` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$select=Ernam,Bukrs,Ebeln` |
| `$expand` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')?$expand=HeadToItemNav` |
| Navigation | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')/HeadToItemNav` |
| `$top` / `$skip` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$top=10&$skip=10` |
| `$count` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet/$count` |
| `$inlinecount` | `GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$inlinecount=allpages` |
| `$value` (media) | `GET /sap/opu/odata/sap/ZSM_SRV/DocumentSet('0000000001')/$value` |
| `$metadata` | `GET /sap/opu/odata/sap/ZSM_SRV/$metadata` |
| `$batch` | `POST /sap/opu/odata/sap/ZSM_SRV/$batch` |

Notes:

- Spaces are shown unencoded for readability. Real requests must percent-encode the query
  string (`%20`, `%27`, `%2c`). `/IWFND/GW_CLIENT` accepts them as typed.
- A single quote inside a string literal is escaped by **doubling** it.
- `$search` is **not** an OData V2 system query option. SAP Gateway instead passes a free-text
  `search=` parameter to the DPC as `IV_SEARCH_STRING`, which the service interprets itself.
- `$format=xlsx` is **SAP-specific**, not standard OData V2, and its availability depends on
  the Gateway release and service configuration.

Full reference with literal forms, escaping and encoding: **[ODATA/README.md](ODATA/README.md)**.

## SAP Gateway Transactions

| Transaction | Purpose |
|---|---|
| `SEGW` | Service Builder — model, generate `MPC_EXT` / `DPC_EXT` |
| `/IWFND/MAINT_SERVICE` | Register/activate services, maintain the system alias, clean the metadata cache |
| `/IWFND/GW_CLIENT` | Test OData requests directly against the Gateway hub, including `$batch` |
| `/IWFND/ERROR_LOG` | Gateway hub error log |
| `/IWBEP/ERROR_LOG` | Backend (BEP) error log |
| `SE11` / `SE24` | Verify DDIC search helps and `/IWBEP/*` interface signatures in your own release |

## Transaction Handling (SAP LUW)

Getting this wrong produces lost updates or premature commits — both invisible in testing and
both damaging in production. **Who owns the commit depends on how the request arrives**, so
the two cases have to be kept apart.

### A. Standalone (non-`$batch`) requests

A single OData request that reaches one CRUD method. Here the application logic may need to
own the commit/rollback decision — depending on the API being called and on whether processing
is local or remote.

1. **Never commit before validating the business result.** Check the return table for `E`
   (error), `A` (abort) **and** `X` (exit) — checking only `'E'` misses aborts. On failure,
   populate the message container and raise; do not commit.
2. **A remote `CALL FUNCTION ... DESTINATION` runs in its own LUW on the target system.** Your
   local commit does not reach it — the commit has to be issued on that destination. A local
   call shares your LUW. The same code path therefore needs a different commit strategy per
   branch. See [`DESTINATION/Destination.abap`](DESTINATION/Destination.abap).
3. **BAPIs do not commit themselves.** The caller owns the commit, by design.
4. **There is no blanket "always commit in DPC_EXT" rule.** Whether a commit belongs in your
   method depends on the API you call and the deployment. Decide it per service and write it
   down.

### B. `$batch` changesets

A changeset is an **atomic LUW** spanning several operations.

5. **During multi-operation changeset processing the provider must not issue its own
   `COMMIT WORK` or `ROLLBACK WORK` inside individual CRUD operations.** The Gateway changeset
   processing owns the commit/rollback boundary.
6. **A premature per-operation commit destroys changeset atomicity.** Once operation 1 has
   committed, a failure in operation 3 can no longer undo it, and the changeset's
   all-or-nothing contract is broken — leaving a partially applied composite change.
7. **Design changeset transaction handling through the changeset lifecycle**
   (`CHANGESET_BEGIN` / `CHANGESET_END` / `CHANGESET_PROCESS` on
   `/IWBEP/IF_MGW_APPL_SRV_RUNTIME`), not by committing inside the CRUD methods. See
   [`BATCH/README.md`](BATCH/README.md).

### Both cases

8. **`commit_work( )` and `rfc_save_log( )` are SEGW-generated DPC conveniences.** Their exact
   signatures and behaviour are release-dependent — verify them in your own system. Note that
   `rfc_save_log( )` is *logging only*: it does not commit and does not affect the response.

The two commit examples in this repository
([`CreateDeepEntity.abap`](DPC_EXT/METHODS/CreateDeepEntity.abap),
[`UpdateEntity.abap`](DPC_EXT/METHODS/UpdateEntity.abap)) demonstrate case **A** — standalone,
RFC-backed request processing. Both carry an explicit warning that their commit must not be
copied into changeset processing.

## Security & Authorization Boundary

**Authentication is not authorization.**

SAP Gateway authenticates the caller (SSO / SAML / OAuth / basic), enforces CSRF protection on
modifying requests, and checks that the user may reach the **service**. It does **not** decide
whether that user may read *this* purchase order, download *this* document, delete *this*
record, or see *that* employee.

Consequences worth stating explicitly:

- **Model flags are metadata, not security.** `set_creatable( )`, `set_updatable( )`,
  `set_deletable( )` and an unimplemented `DELETE_ENTITY` shape `$metadata` and what a Fiori
  UI renders. A direct HTTP request is unaffected.
- **A key in the URL is a client-supplied value.** Document IDs, entity keys and stream keys
  are chosen by the caller and can be enumerated. Authorize before returning content.
- **HTTP request headers are not identity.** A header such as `request_user` is
  attacker-controllable. Use `sy-uname` for anything security-relevant. See
  [`SYSTEM/UserInfo.abap`](SYSTEM/UserInfo.abap).
- **Trusted RFC propagates identity, not authorization.** The called function module is still
  responsible for checking whether that user may perform the action. Where a destination uses a
  technical user, the caller's identity is lost entirely and all authorization must happen
  before the call.
- **A state-changing function import should be modelled as `POST`, not `GET`.** `GET` is
  defined as safe, may be prefetched or cached, and bypasses CSRF token enforcement.
- **Value helps over personal data need the application's own authorization.** A search help
  does not carry it.

The examples in this repository mark where an authorization check belongs and **deliberately
do not invent an authorization object**, because the correct one is application-specific.
Treat every such marker as required work, not as an optional extra.

## Gateway Classes & Interfaces

Only APIs actually used in this repository:

| API | Used for |
|---|---|
| `/IWBEP/IF_MGW_APPL_SRV_RUNTIME` | DPC_EXT runtime methods — CRUDQ, deep entities, expands, streams, function imports |
| `/IWBEP/IF_MGW_ODATA_MODEL`, `…_ENTITY_TYP`, `…_ENTITY_SET`, `…_PROPERTY`, `…_ANNOTATION` | MPC_EXT model access |
| `/IWBEP/IF_MGW_ODATA_ANNOTATABL` | `sap:` MED annotations |
| `/IWBEP/IF_MGW_VOCAN_MODEL` and the `…_VOCAN_*` family | Vocabulary annotations (`ValueList`) |
| `/IWBEP/CX_MGW_MED_EXCEPTION` | Modelling errors in `DEFINE` |
| `/IWBEP/CL_MGW_DATA_UTIL` | `filtering( )`, `orderby( )`, `paging( )` |
| `/IWBEP/CX_MGW_BUSI_EXCEPTION`, `/IWBEP/CX_MGW_TECH_EXCEPTION` | Business (4xx-class) vs technical (5xx-class) errors |
| `/IWBEP/IF_MESSAGE_CONTAINER` | `add_message`, `add_message_text_only`, `add_messages_from_bapi` |
| `/IWBEP/IF_SB_DPC_COMM_SERVICES` | `rfc_save_log( )`, `commit_work( )` |
| `/IWBEP/IF_SB_GENDPC_SHLP_DATA` | `get_search_help_values( )` — DDIC search helps |
| `/IWBEP/IF_MGW_CONV_SRV_RUNTIME`, `/IWBEP/IF_MGW_DP_FACADE`, `/IWBEP/CL_SB_GEN_DPC_RT_UTIL` | RFC destination resolution |
| `/IWFND/C_MGDEAM`, `/IWFND/I_MED_SRH`, `/IWFND/C_DFSYAL` | Gateway configuration tables — *diagnostic reading only, not a released API* |

Signatures vary across `SAP_GWFND` releases. Points that could not be verified without a
connected system are marked **`NEEDS OFFICIAL VERIFICATION`** in the code rather than guessed.

## Conventions & Scope

- **Most `.abap` files are cookbook method bodies, not complete classes.** Files containing
  several `METHOD` blocks — sometimes with the *same* name — hold **independent alternative
  implementations** of one generated method. Pick one; do not paste them together. Each such
  file states this in its header.
- **Alternatives are never left both active.** Where two approaches are shown, one is live and
  the other is commented out, so nothing is sorted twice or appended twice.
- **Identifiers are placeholders.** `ZSM*`, `zcl_zsm_*`, `zsm_t_*`, `ZSM_F_*` and the entity,
  property and service names stand in for what your own SEGW project generates. They will not
  exist in your system as-is.
- **Standard SAP objects are real.** Tables (`MARA`, `T001`, …), search helps (`H_T001`,
  `MAT0M`, `PM02`, …) and `/IWBEP/*` / `/IWFND/*` APIs are named accurately.
- **Uncertainty is labelled, not guessed.** Release-specific signatures and behaviours carry a
  `NEEDS OFFICIAL VERIFICATION` marker.
- **Validation is static.** The ABAP in this repository has been reviewed by reading, not
  compiled, activated or ATC-checked against a connected SAP system. Treat every example as a
  pattern to adapt and syntax-check in your own system, not as drop-in code.

## Disclaimer

- Independent reference examples, not official SAP documentation, and not endorsed by SAP.
- Behaviour varies across SAP releases and support packages — validate in your own system
  before relying on it.
- Examples are illustrative and are **not production-ready as written**: they omit the business
  authorization, validation and persistence logic that a real service requires.
- Object names, system IDs, RFC destinations and hostnames throughout this repository are
  neutral placeholders (`DEV` / `QAS` / `PRD`, `EXAMPLE_RFC_*`, `example.sap.system`, `JDOE`,
  `ZSM*`). Standard SAP object names are used accurately and intentionally.
- Screenshots that could not be sanitised without losing their technical point were removed and
  replaced with written documentation. Note that this applies to the **current tree**; earlier
  commits in this repository's history still contain those files.

## Contributing

A personally maintained reference. Small, focused improvements — corrections, clarifications,
additional practical patterns — are welcome via PR.

## License

MIT — see [LICENSE](LICENSE).

## Author

**Serhat Mercan** — SAP technical consultant and developer. SAP BTP, ABAP, CDS, Fiori/UI5 and
technical architecture, with hands-on SAP Gateway and enterprise integration experience
underneath.
