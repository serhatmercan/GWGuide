# Field-Level Value Help Sources (DDIC check tables and text tables)

Reference for building **custom OData value helps** — either a dedicated `*ValueHelpSet`
entity set backed by a `GET_ENTITYSET`, or a `com.sap.vocabularies.Common.v1.ValueList`
vocabulary annotation in `MPC_EXT`.

> **What this file is.** For each SAP field it lists the DDIC **check/selection table** that
> holds the allowed values and the **text table** that holds their descriptions — the two
> pieces you need to build a key/description value help yourself.
>
> **What this file is not.** It does not list custom (`Z`) search helps. If you want a ready
> SAP-delivered search help object, see [`StandardSearchHelps.md`](StandardSearchHelps.md).

All entries are **standard SAP** fields and tables.

## How to use an entry

Take `Matkl` (material group) as an example: values live in `T023`, descriptions in `T023T`.

1. Model a `MaterialGroupVHSet` entity set with `Matkl` and `Wgbez` properties.
2. Read `T023` joined to `T023T` (on `SPRAS = sy-langu`) in its `GET_ENTITYSET`.
3. Bind it in `MPC_EXT` — see `add_value_help( )` in
   [`../MPC_EXT/METHODS/UtilClass.abap`](../MPC_EXT/METHODS/UtilClass.abap):

```abap
lo_mpc_util->add_value_help( iv_annotation_target = 'ZSM_SRV.Header/Matkl'
                             iv_entity_set_name   = 'MaterialGroupVHSet'
                             iv_key_name          = 'Matkl'
                             iv_text_name         = 'Wgbez' ).
```

For small, stable domains prefer a fixed-value dropdown instead — `set_drop_down_list( )` /
`sap:semantics='fixed-values'` — which avoids a round trip entirely.

## Reference table

| Field | Text Field | Check / Selection Table | Text Table | Description (EN) | Description (TR) |
|---|---|---|---|---|---|
| Arbpl | | CRHD | | Work Center | İş Merkezi |
| Auart | Bezei | T350 | TVAKT | Sales Document Type | Satış Belgesi Türü |
| Auart | Txt30 | | T003P | Order Type | Sipariş Türü |
| Blart | Ltext | T003 | T003T | Document Type | Belge Türü |
| Bname | | USR02 | | User Name | Kullanıcı Adı |
| Bsart | Batxt | T161 | T161T | Purchasing Document Type | Satınalma Belgesi Türü |
| Bschl | Ltext | TBSL | TBSLT | **Posting Key** | Kayıt Anahtarı |
| Bukrs | Butxt | T001 | | **Company Code** | Şirket Kodu |
| Bzirk | Bztxt | T171 | T171T | Sales District | Satış Bölgesi |
| Eqart | Eartx | T370K | T370K_T | Object Type | Nesne Türü |
| Eqtyp | Typtx | T370T | T370U | Equipment Type | Ekipman Tipi |
| Equnr | Eqktx | EQUI | EQKT | Equipment | Ekipman |
| Extwg | Ewbez | TWEW | TWEWT | External Material Group | Harici Mal Grubu |
| Fkart | Vtext | TVFK | TVFKT | Billing Type | Faturalama Türü |
| Inco1 | Bezei | TINC | TINCT | Incoterms | Teslim Şekli |
| Ingrp | | T024I | | Maintenance Planner Group | Bakım Planlama Grubu |
| Kdgrp | Ktext | T151 | T151T | Customer Group | Müşteri Grubu |
| Konda | Vtext | T188 | T188T | Customer Price Group | Müşteri Fiyat Grubu |
| Ktokd | Txt30 | T077X | | Customer Account Group | Müşteri Hesap Grubu |
| Ktokk | Txt30 | T077Y | | Vendor Account Group | Satıcı Hesap Grubu |
| Kunnr | Name1 | KNA1 | | Customer | Müşteri |
| Kurst | Curvw | TCURV | TCURW | Exchange Rate Type | Kur Tipi |
| Land1 | Landx | T005 | T005T | Country / Region Key | Ülke / Bölge Anahtarı |
| Lgort | Lgobe | | T001L | **Storage Location** | Depo Yeri |
| Matkl | Wgbez | T023 | T023T | Material Group | Mal Grubu |
| Matnr | Maktx | | MAKT | Material | Malzeme |
| Mtart | Mtbez | T134 | T134T | **Material Type** | Malzeme Türü |
| Pltyp | Ptext | T189 | T189T | Price List Type | Fiyat Listesi Tipi |
| Priok | Tagen | T356 | | Priority | Öncelik |
| Prodh | Vtext | T179 | T179T | Product Hierarchy | Ürün Hiyerarşisi |
| Pstyp | Ptext | T163Y | | Item Category | Kalem Tipi |
| Stawn | Text1 | T604 | T604T | Commodity Code | İstatistiksel Mal Numarası |
| Tcode | Ttext | TSTC | TSTCT | Transaction Code | İşlem Kodu |
| Tplnr | Pltxt | IFLOT | IFLOTX | Functional Location | Teknik Yer |
| Traty | Vtext | TVTY | TVTYT | Packaging Material Type | Ambalaj Malzemesi Türü |
| Vkbur | Bezei | | TVKBT | Sales Office | Satış Bürosu |
| Vkgrp | Bezei | TVKGR | TVGRT | Sales Group | Satış Grubu |
| Vkorg | | TVKO | TVKOT | Sales Organization | Satış Organizasyonu |
| Vtweg | Vtext | TVTW | TVTWT | Distribution Channel | Dağıtım Kanalı |
| Waers | Ktext | TCURC | TCURT | Currency | Para Birimi |
| Werks | Name1 | T001W | | **Plant** | Üretim Yeri |

Notes:

- Text tables are language-dependent — always select with `SPRAS = sy-langu` and handle the
  fallback when no text exists in the logon language.
- Where the *Check / Selection Table* column is blank, the values come from the application
  table itself (e.g. `MATNR` from `MARA`, with descriptions in `MAKT`).
- `BUT000` / business-partner-based lookups vary by BP role configuration and are not listed
  here; verify the intended role and field in your own system before using one as a value help.

## Related

- [`StandardSearchHelps.md`](StandardSearchHelps.md) — SAP-delivered search help objects
- [`../MPC_EXT/METHODS/UtilClass.abap`](../MPC_EXT/METHODS/UtilClass.abap) — `add_value_help( )`, `set_drop_down_list( )`
- [`../DPC_EXT/METHODS/GetEntitySet.abap`](../DPC_EXT/METHODS/GetEntitySet.abap) — search-help-backed `GET_ENTITYSET`
