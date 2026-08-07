# SAP Gateway / OData V2 Guide

Personal Notes, ABAP Examples & Practical Reference

## Overview

This repository contains personal SAP Gateway / OData V2 notes and practical ABAP examples collected while building and maintaining SEGW-based Gateway services (`MPC_EXT` / `DPC_EXT`). It is not a tutorial from scratch — it's a working reference of patterns actually used in projects: CRUDQ methods, deep entities, media streams, function imports, filtering/paging/sorting, error handling, RFC destination resolution, and search help lookups.

## Purpose

Use this repository to speed up:

- OData V2 service development in SEGW
- `MPC_EXT` model annotation (labels, value help, filter/sort flags, media, tree tables)
- `DPC_EXT` CRUDQ method implementation (`GET_ENTITY(SET)`, `CREATE`, `UPDATE`, `DELETE`)
- Deep entity create/read (`CREATE_DEEP_ENTITY`, `GET_EXPANDED_ENTITY(SET)`)
- Media/stream handling (`CREATE_STREAM`, `GET_STREAM`)
- Query options: `$filter`, `$orderby`, `$top`, `$skip`, `$inlinecount`, `$expand`
- Gateway error/message handling
- RFC destination resolution and remote-enabled function calls
- Search help (value help) reference lookups

## Target Audience

- SAP ABAP developers
- SAP Gateway developers
- SAP Fiori backend developers
- SAP technical consultants

## Repository Structure

```
BATCH/                       $batch request screenshot reference
DATA_MODEL/                  SEGW data model screenshots
  COMPLEX_TYPES/
  ENTITY_TYPES/
  FUNCTION_IMPORTS/
DESTINATION/
  Destination.abap           RFC destination resolution patterns
DPC_EXT/
  METHODS/                   DPC_EXT runtime method examples (CRUDQ, deep entity, media, actions, exceptions)
MPC_EXT/
  METHODS/                   MPC_EXT DEFINE annotations + reusable util class
  TYPES/                     Deep-entity type definitions
ODATA/
  OData.txt                  OData V2 URI quick reference
  CustomSH.txt / CustomSH.md     Custom (field-level) search help reference
  StandardSH.txt / StandardSH.md Standard SAP search help reference
SYSTEM/
  UserInfo.abap              Request context / session / user examples
```

## Learning Path

1. OData V2 basics — [ODATA/OData.txt](ODATA/OData.txt)
2. Data Model — [DATA_MODEL/](DATA_MODEL/)
3. MPC_EXT — [MPC_EXT/METHODS/Define.abap](MPC_EXT/METHODS/Define.abap), [MPC_EXT/METHODS/UtilClass.abap](MPC_EXT/METHODS/UtilClass.abap)
4. DPC_EXT CRUDQ — [DPC_EXT/METHODS/GetEntitySet.abap](DPC_EXT/METHODS/GetEntitySet.abap), [GetEntity.abap](DPC_EXT/METHODS/GetEntity.abap), [CreateEntity.abap](DPC_EXT/METHODS/CreateEntity.abap), [UpdateEntity.abap](DPC_EXT/METHODS/UpdateEntity.abap), [DeleteEntity.abap](DPC_EXT/METHODS/DeleteEntity.abap)
5. Associations / Expand — [GetExpandedEntity.abap](DPC_EXT/METHODS/GetExpandedEntity.abap), [GetExpandedEntitySet.abap](DPC_EXT/METHODS/GetExpandedEntitySet.abap)
6. Function Imports / Actions — [ExecuteAction.abap](DPC_EXT/METHODS/ExecuteAction.abap), [DATA_MODEL/FUNCTION_IMPORTS/](DATA_MODEL/FUNCTION_IMPORTS/)
7. Deep Entity — [CreateDeepEntity.abap](DPC_EXT/METHODS/CreateDeepEntity.abap), [MPC_EXT/TYPES/Types.abap](MPC_EXT/TYPES/Types.abap)
8. Media / Stream — [CreateStream.abap](DPC_EXT/METHODS/CreateStream.abap), [GetStream.abap](DPC_EXT/METHODS/GetStream.abap), [DocumentGetEntitySet.abap](DPC_EXT/METHODS/DocumentGetEntitySet.abap)
9. Error Handling — [Exception.abap](DPC_EXT/METHODS/Exception.abap)
10. Destination / RFC — [DESTINATION/Destination.abap](DESTINATION/Destination.abap)
11. Search Help / Utilities — [ODATA/CustomSH.md](ODATA/CustomSH.md), [ODATA/StandardSH.md](ODATA/StandardSH.md)
12. System/User context — [SYSTEM/UserInfo.abap](SYSTEM/UserInfo.abap)
13. $batch — [BATCH/Batch.png](BATCH/Batch.png)

## Quick OData V2 Reference

| Purpose | Example |
|---|---|
| GET EntitySet | `GET /ZSM_SRV/POHeaderSet` |
| GET Entity | `GET /ZSM_SRV/POHeaderSet('4500000005')` |
| $filter | `GET /ZSM_SRV/POHeaderSet?$filter=Erdat ge datetime'2021-12-26-15T00:00:00'` |
| $orderby | `GET /ZSM_SRV/POHeaderSet?$orderby=Erdat desc` |
| $select | `GET /ZSM_SRV/POHeaderSet?$select=Ernam,Bukrs,Ebeln` |
| $expand | `GET /ZSM_SRV/POHeaderSet('4500000005')/?$expand=HeadToItemNav` |
| $top / $skip | `GET /ZSM_SRV/POHeaderSet?$top=10&$skip=10` |
| $count | `GET /ZSM_SRV/POHeaderSet/$count` |
| $inlinecount | `GET /ZSM_SRV/POHeaderSet?$inlinecount=allpages` |

Full list with more variations: [ODATA/OData.txt](ODATA/OData.txt).

## SAP Gateway Transactions Used In This Guide

| Transaction | Purpose |
|---|---|
| `SEGW` | Service Builder — model, MPC_EXT/DPC_EXT generation |
| `/IWFND/MAINT_SERVICE` | Activate/register services, System Alias (destination) maintenance |
| `/IWFND/GW_CLIENT` | Test OData requests directly against the Gateway hub |
| `/IWFND/ERROR_LOG` | Gateway hub error log |
| `/IWBEP/ERROR_LOG` | Backend (BEP) error log |

## Important SAP Gateway Classes / Interfaces

Only APIs actually used in this repository:

- `/IWBEP/IF_MGW_APPL_SRV_RUNTIME` — DPC_EXT runtime method interface (GET/CREATE/UPDATE/DELETE, streams, actions)
- `/IWBEP/CL_MGW_DATA_UTIL` — `filtering()`, `paging()`, `orderby()` helpers
- `/IWBEP/CX_MGW_BUSI_EXCEPTION`, `/IWBEP/CX_MGW_TECH_EXCEPTION` — Gateway exception types
- `/IWBEP/IF_MESSAGE_CONTAINER` — message container (`add_message`, `add_messages_from_bapi`)
- `/IWBEP/IF_SB_DPC_COMM_SERVICES` — `rfc_save_log()`, `commit_work()`
- `/IWBEP/IF_MGW_CONV_SRV_RUNTIME`, `/IWBEP/IF_MGW_DP_FACADE` — RFC destination resolution
- `/IWBEP/IF_MGW_ODATA_ANNOTATABL`, `/IWBEP/IF_MGW_VOCAN_MODEL` — MPC_EXT MED annotations & vocabulary annotations (value help)

## OData V2 vs OData V4

This guide is specifically about **SAP Gateway / OData V2**. OData V4 concepts are **not covered by this guide** and are not used as a substitute for V2 behavior anywhere in these examples.

## Disclaimer

- These are personal reference examples, not official SAP documentation.
- Behavior can vary across SAP releases/support packages — validate in your own system before relying on it.
- Examples use custom `Z`/`ZSM` objects as placeholders for a real project namespace; class/table/RFC names will not exist in your system as-is.
- Destination names, usernames, and hostnames have been replaced with generic placeholders for publication.

## Contributing

This is primarily a personal study reference, but small, focused improvements (typo fixes, additional practical examples, corrections) are welcome via PR.

## License

See [LICENSE](LICENSE).

## Contact

Serhat Mercan
