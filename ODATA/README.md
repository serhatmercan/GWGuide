# OData V2 — URI Anatomy and Query Reference (SAP Gateway)

Canonical protocol reference for this repository. **OData V2 only** — this is the protocol
version SAP Gateway serves for SEGW-based services. No V4 syntax appears here.

Sample service used throughout:

```
Project:      ZSM
Service:      ZSM_SRV
Service root: https://example.sap.system:44300/sap/opu/odata/sap/ZSM_SRV/
```

All values are generic placeholders.

## URI anatomy

An OData request URI decomposes into five parts:

```
https://example.sap.system:44300/sap/opu/odata/sap/ZSM_SRV/POItemSet?$select=Ebeln,Ebelp,Matnr
└─┬──┘ └────────┬───────────┘└──────────┬──────────────┘└────┬────┘ └──────────┬──────────┘
scheme        authority              service root      resource path      query options
              (host:port)
```

| Part | Value in the example | Notes |
|---|---|---|
| **Scheme** | `https` | `http` / `https`. Use `https` in any real landscape. |
| **Authority** | `example.sap.system:44300` | Host and port of the Gateway hub (or the embedded system). |
| **Service root** | `/sap/opu/odata/sap/ZSM_SRV/` | Fixed SAP Gateway prefix `/sap/opu/odata/sap/` plus the registered service name. A version suffix may appear: `ZSM_SRV;v=2`. |
| **Resource path** | `POItemSet` | Entity set, entity, property, navigation property, `$metadata`, `$batch`, `$count` or `$value`. |
| **Query options** | `$select=Ebeln,Ebelp,Matnr` | System query options (`$`-prefixed) and custom/SAP parameters. |

*Scheme + authority + service root + resource path* forms the URL; the whole string including
query options is the URI.

## Service document and metadata

```
GET /sap/opu/odata/sap/ZSM_SRV/              service document — lists the entity sets
GET /sap/opu/odata/sap/ZSM_SRV/$metadata     EDMX metadata — types, keys, associations,
                                             navigation properties, function imports,
                                             media flags, sap: annotations
```

`$metadata` is the first thing to check when a label, value help or filter flag does not
behave as expected in a Fiori application — everything modelled in SEGW and `MPC_EXT` appears
there.

## Reading entities

```
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet                          entity set (query)
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')            single entity
GET /sap/opu/odata/sap/ZSM_SRV/POItemSet(Ebeln='4500000000',Ebelp='00010')   composite key
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')/Bukrs      single property
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')/Bukrs/$value   raw property value
GET /sap/opu/odata/sap/ZSM_SRV/DocumentSet('0000000001')/$value     media resource content
```

### Key syntax

The key literal form depends on the EDM type:

| Key type | Syntax | Example |
|---|---|---|
| `Edm.String` | quoted | `POHeaderSet('4500000005')` |
| `Edm.Int32` / `Edm.Int64` / `Edm.Decimal` | **unquoted** | `ProductSet(42)` |
| `Edm.Guid` | `guid'…'` | `DocumentSet(guid'005056a5-1f2e-1eda-8fb2-1a2b3c4d5e6f')` |
| `Edm.DateTime` | `datetime'…'` | `LogSet(datetime'2024-11-13T00:00:00')` |
| Composite | `Name=value` pairs, comma-separated | `POItemSet(Ebeln='4500000000',Ebelp='00010')` |

Keys travel in **external** format — the ALPHA/conversion-exit-converted form the user sees.
`io_tech_request_context->get_converted_keys( )` hands them to your DPC already converted to
internal format; `get_keys( )` returns them raw. See
[`../DPC_EXT/METHODS/GetEntity.abap`](../DPC_EXT/METHODS/GetEntity.abap).

## Navigation and `$expand`

```
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')/HeadToItemNav
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')?$expand=HeadToItemNav
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$expand=HeadToItemNav
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet('4500000005')?$expand=HeadToItemNav/ItemToSchedNav
```

- The **first** form *navigates* — it returns the children only.
- The **second** form *expands* — it returns the parent with the children inline.
- No slash before `?`. `…POHeaderSet('4500000005')?$expand=…` is the canonical form.
- Multi-level expands use `/` between navigation property names; several expands are
  comma-separated.

On the ABAP side, navigation is served by `GET_ENTITYSET` (via `it_navigation_path` /
`iv_source_name`); `$expand` is served by `GET_EXPANDED_ENTITY` / `GET_EXPANDED_ENTITYSET`.

## System query options

| Option | Example | Notes |
|---|---|---|
| `$filter` | `?$filter=Bukrs eq '1000'` | See below |
| `$orderby` | `?$orderby=Erdat desc,Ebeln asc` | `asc` is the default |
| `$select` | `?$select=Ernam,Bukrs,Ebeln` | Comma-separated, no spaces |
| `$expand` | `?$expand=HeadToItemNav` | See above |
| `$top` | `?$top=10` | Page size |
| `$skip` | `?$skip=10` | Offset |
| `$inlinecount` | `?$inlinecount=allpages` | `allpages` or `none`; `allpages` adds `__count` to the response |
| `$format` | `?$format=json` | `json` or `xml` |
| `$count` | `POHeaderSet/$count` | **Path segment**, not a query option. Returns a bare integer as `text/plain`. |
| `$value` | `DocumentSet('…')/$value` | Path segment — raw property value or media content |
| `$metadata` | `ZSM_SRV/$metadata` | Path segment |
| `$batch` | `ZSM_SRV/$batch` | Path segment, `POST` only — see [`../BATCH/README.md`](../BATCH/README.md) |

### `$top` / `$skip` paging

```
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$top=10                        page 1
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$top=10&$skip=10               page 2
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$top=10&$skip=10&$inlinecount=allpages
```

Combine `$top`/`$skip` with `$orderby` for stable paging — without a deterministic sort order
the "next page" is not well defined.

### `$count` vs `$inlinecount`

- `$count` is a **path segment** returning only a number:
  `GET …/POHeaderSet/$count` → `137`
- `$inlinecount=allpages` is a **query option** that adds the total to a normal collection
  response, so one request returns both the page and the total:

```json
{ "d": { "results": [ … ], "__count": "137" } }
```

`__count` reflects the total **after `$filter`, before `$top`/`$skip`** — that ordering is
what makes it useful for a paged table, and it is what the DPC examples in this repository
implement. `__count` must only be returned when the client asked for it.

### `$filter`

Operators: `eq` `ne` `gt` `ge` `lt` `le`, combined with `and` / `or` / `not` and parentheses.
Functions include `substringof`, `startswith`, `endswith`, `tolower`, `toupper`, `length`.

```
?$filter=Bukrs eq '1000'
?$filter=Bukrs eq '1000' and Werks eq '0001'
?$filter=Erdat ge datetime'2021-12-26T00:00:00' and Erdat le datetime'2022-12-26T00:00:00'
?$filter=substringof('EXAMPLE',Ernam)
?$filter=startswith(Matnr,'A')
?$filter=Netwr gt 1000.00m
```

**Literal forms:**

| EDM type | Literal | Example |
|---|---|---|
| `Edm.String` | `'…'` | `'1000'` |
| `Edm.DateTime` | `datetime'yyyy-mm-ddThh:mm:ss'` | `datetime'2021-12-26T00:00:00'` |
| `Edm.Time` | `time'PT08H30M'` | duration form |
| `Edm.DateTimeOffset` | `datetimeoffset'…'` | separate type — `Edm.DateTime` carries **no** offset |
| `Edm.Decimal` | numeric with `m` suffix | `1000.00m` |
| `Edm.Guid` | `guid'…'` | `guid'005056a5-…'` |
| `Edm.Boolean` | `true` / `false` | unquoted |

### Escaping and encoding

**A single quote inside a string literal is escaped by doubling it:**

```
?$filter=Name eq 'O''Brien'
DocumentSet(FileId='IT''S-A-KEY')
```

**Percent-encode the query string in real requests.** The examples in this file are written
unencoded for readability, and `/IWFND/GW_CLIENT` accepts them as typed — but a client library
or `curl` needs them encoded:

| Character | Encoded |
|---|---|
| space | `%20` |
| `'` | `%27` |
| `,` | `%2c` |
| `/` | `%2f` |
| `$` | `%24` (in values; system query option names are not encoded) |

```
?$filter=Bukrs%20eq%20%271000%27
?$select=Ebeln%2cEbelp%2cMatnr
```

The same applies when your DPC *builds* a URL: interpolating a raw key into a `$value` URL
without escaping breaks on any key containing `'`. See
[`../DPC_EXT/METHODS/DocumentGetEntitySet.abap`](../DPC_EXT/METHODS/DocumentGetEntitySet.abap).

## `$search` and free-text search

**`$search` is not an OData V2 system query option** — it was introduced in OData V4. Do not
expect it to work against a V2 Gateway service.

SAP Gateway V2 provides its own free-text search mechanism instead. A `search=` URL parameter
is passed through to the DPC as the **`IV_SEARCH_STRING`** importing parameter of
`GET_ENTITYSET`, which the implementation may interpret however the application requires:

```
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?search=example
```

```abap
METHOD xxxset_get_entityset.
  " iv_search_string carries the free-text search term, if the client sent one.
  " It is NOT an OData V4 $search implementation - the service decides what it means.
  IF iv_search_string IS NOT INITIAL.
    " apply your own free-text selection here
  ENDIF.
ENDMETHOD.
```

Every `GET_ENTITYSET` signature in this repository carries `iv_search_string`; whether it is
honoured is entirely up to the service.

## SAP-specific URL parameters

These are **not** OData system query options. They are SAP Gateway / SAP NetWeaver URL
parameters and are release- and configuration-dependent.

| Parameter | Purpose |
|---|---|
| `sap-client=100` | Logon client |
| `sap-language=EN` | Logon language |
| `sap-statistics=true` | Return Gateway performance statistics headers |
| `$format=xlsx` | **SAP-specific.** Spreadsheet export. Not an OASIS OData V2 `$format` value — availability depends on the SAP Gateway release and on the service/hub configuration. Do not rely on it as a standard feature. |

```
GET /sap/opu/odata/sap/ZSM_SRV/POHeaderSet?$format=json&sap-language=EN
```

## Modifying operations

| HTTP method | Meaning | DPC_EXT method |
|---|---|---|
| `POST` on an entity set | Create | `~CREATE_ENTITY` / `~CREATE_DEEP_ENTITY` |
| `PUT` on an entity | Full replace | `~UPDATE_ENTITY` |
| `MERGE` / `PATCH` on an entity | Partial update | `~UPDATE_ENTITY` |
| `DELETE` on an entity | Delete | `~DELETE_ENTITY` |

All modifying requests require an **`X-CSRF-Token`**. Fetch it with a `GET` carrying
`X-CSRF-Token: Fetch` and send it back on the modifying request. `$batch` is a `POST` and
therefore also requires it.

Function imports are invoked as `GET` or `POST` depending on how they were modelled — see
[`../DATA_MODEL/README.md`](../DATA_MODEL/README.md).

## Testing

| Tool | Use |
|---|---|
| `/IWFND/GW_CLIENT` | Issue requests directly against the hub, including `$batch` |
| `/IWFND/ERROR_LOG` | Hub-side errors |
| `/IWBEP/ERROR_LOG` | Backend-side errors |
| `/IWFND/MAINT_SERVICE` | Registration, system alias, metadata cache cleanup |
| Browser dev tools | Inspect what a Fiori/UI5 application actually sends |

## Related

- [`../BATCH/README.md`](../BATCH/README.md) — `$batch` and changesets
- [`../DATA_MODEL/README.md`](../DATA_MODEL/README.md) — the model behind these URIs
- [`ValueHelpSources.md`](ValueHelpSources.md) — field/table sources for value helps
- [`StandardSearchHelps.md`](StandardSearchHelps.md) — standard SAP search helps
