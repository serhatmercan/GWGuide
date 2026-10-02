# CLAUDE.md — GWGuide

Coding rules: docs/Gateway-Development-Rules.md (planned; until it exists, follow the existing files).

## Purpose and scope
- Practical classic SAP Gateway reference: SEGW, `MPC_EXT` / `DPC_EXT`,
  OData V2. Most `.abap` files are cookbook method bodies, not classes.
- Out of scope: OData V4 syntax (`$search` included), RAP, service
  definitions/bindings, CDS-based exposure, migration paths; boundary map:
  CLASSIC-GATEWAY-VS-MODERN-SERVICE-MODEL.md. Say "function import", not
  "action".
- No deprecation claim about SEGW or OData V2. `CLASSIC BUT STILL RELEVANT`
  is carried only by the boundary map and the root README; individual
  files carry lifecycle labels only for `VERSION-DEPENDENT` constructs.
- Only the Gateway side is explained here. ABAP language topics link to
  ABAPGuide (https://github.com/serhatmercan/ABAPGuide), CDS topics to
  CDSGuide (https://github.com/serhatmercan/CDSGuide), UI5 consumption to
  UIGuide (https://github.com/serhatmercan/UIGuide).
- Service URLs, system aliases, hostnames, client numbers, user names and
  screenshots of real systems never appear. Use `example.sap.system`,
  `DEV` / `QAS` / `PRD`, `EXAMPLE_RFC_*`, `JDOE`. Existing conflicts
  (`sap-client=100`, `TextElements.png`, "Description (TR)" columns) are
  fixed in the planned pass.

## Structure
- Upper-case topic folders (`DPC_EXT/METHODS/`, `ODATA/`); code files
  `PascalCase.abap` named after the method or mechanism; prose files
  `README.md` or `PascalCase.md`.
- Markdown title `# Topic — qualifier` (em dash); `##` headings carry no
  emoji. Order: lead paragraph → topic sections → `## Testing` (optional)
  → `## Related`.
- `.abap` header between `*&---` rules: `*& METHOD_NAME - purpose`,
  `*& REFERENCE COOKBOOK - READ BEFORE COPYING`, the snippet kind, then
  upper-case sections (`AUTHORIZATION BOUNDARY`, `TRANSACTION (SAP LUW)`).
- Snippet kind: "Independent reference method body" by default, otherwise
  `SKELETON EXAMPLE`, `STATEMENT FRAGMENTS`, `TYPE-DEFINITION FRAGMENT` or
  "complete class". Several bodies in one file open with
  `*& Example N - <title>` banners; only one alternative is live.
- New files go into the root README "Repository Structure" and, where
  relevant, "Highlights", "Learning Path", "Gateway Classes & Interfaces".

## Labels
- Exactly five lifecycle labels, shared with ABAPGuide and CDSGuide:
  `CURRENT / RECOMMENDED`, `CLASSIC BUT STILL RELEVANT`,
  `LEGACY / HISTORICAL REFERENCE`, `ABAP CLOUD / MODERN CONTEXT`,
  `VERSION-DEPENDENT`.
- Markdown: ``> **Lifecycle:** `LABEL`. <one or two sentences>`` and
  `> ⚠️ **VERSION-DEPENDENT: <feature>.** <text>`; in `.abap` comments
  `VERSION-DEPENDENT: <feature>.`.
- Existing `NEEDS OFFICIAL VERIFICATION` markers are split in the planned
  pass; add no new ones. Release-dependent behaviour becomes
  `VERSION-DEPENDENT`; an API that is not released gets
  ``> 📝 **Not a released API.** Verify availability and stability in your system.``
  (in `.abap` comments: `NOT A RELEASED API - verify in your system.`).
- Callouts: `> ⚠️` pitfalls, `> 💡` tips, `> 📝` notes, `> 🔐` security,
  each with a bold lead and one idea. Existing emoji-free callouts are
  migrated in the planned pass.
- Code warnings are upper-case banners:
  `" <-- BUSINESS AUTHORIZATION CHECK BELONGS HERE.` and `" STANDALONE REQUEST ONLY - DO NOT COPY INTO CHANGESET PROCESSING`.

## Code examples
- Fences: ```` ```abap ````, ```` ```http ```` (raw requests), ```` ```json ````
  (payloads); untagged for URIs and trees.
- Placeholders: project `ZSM`, service `ZSM_SRV`; generated classes
  `zcl_zsm_mpc(_ext)` / `zcl_zsm_dpc(_ext)` (SEGW's generated-name
  pattern) with `ts_<entity>` types; own classes `zcl_zsm_<name>`;
  function modules `ZSM_FM_<name>`; `zsm_t_` table, `zsm_s_` structure,
  `zsm_tt_` table type; message class `zsm_msg`; method
  `xxxset_get_entity`.
- Variant placeholders (`EXAMPLE_SRV`, `ZSM_EXAMPLE`, `zcl_zsm_001_mpc_ext`,
  ...) are aligned in the planned pass; do not add new ones.
- Entity types singular PascalCase (`Header`); sets add `Set`, value helps
  `VHSet` (`MaterialGroupVHSet`); navigation `<Source>To<Target>Nav`.
- ABAP naming follows SAP's Clean ABAP style guide: descriptive names
  without type or scope prefixes (`sales_orders`, not `lt_vbak`).
  Exceptions: names fixed by a signature you do not own (SEGW-generated
  methods and types such as `io_tech_request_context`, `et_entityset`,
  `er_entity` and `ts_<entity>`, BAPI and function module interfaces,
  inherited or interface methods) stay as they are. Existing examples are
  migrated in the planned pass; legacy-labelled examples keep their
  construct but use current naming.
- Comments: `"` with `" ---` rules, numbered steps `" 1) ...`, ASCII
  hyphens only.
- Mark where business authorization belongs; never invent an authorization
  object. Identity is `sy-uname`, never a header; URI keys, Slug and MIME
  type are untrusted. Model flags are metadata, not security; a
  state-changing function import is `POST`.
- CRUD methods issue no `COMMIT WORK` by default. A commit appears only for
  a standalone request, after the `E` / `A` / `X` check, under the
  standalone banner. Changesets use the `CHANGESET_*` lifecycle methods.
- Fill the message container before raising; `..._BUSI_EXCEPTION` for
  business, `..._TECH_EXCEPTION` for technical faults. No empty `CATCH`,
  no raw exception text in a response.

## Links
- Relative links only; link text is the href in backticks
  (``[`../BATCH/README.md`](../BATCH/README.md)``), except in root README
  tables and in-page anchors. Related list: ``- [`path`](path) — reason``.
- `.abap` comments name files by repo-root path (file name in the same
  folder) and README sections by quoted heading name.
- External links are limited to official SAP documentation (help.sap.com)
  and the sibling guides in github.com/serhatmercan.
