# Standard SAP Search Helps (SHLP) for OData Value Helps

SAP-delivered elementary and collective search helps (`SE11` → Search help) that can back an
OData value help. Several are keyed together with a related field — e.g. plant plus material,
or sales organisation plus distribution channel — which is exactly what a dependent
(cascading) value help needs.

All entries are **standard SAP objects**. Nothing here is customer-specific.

## Two ways to use these

**1. Call the search help from a `GET_ENTITYSET`.** The SEGW-generated DPC exposes
`/IWBEP/IF_SB_GENDPC_SHLP_DATA~GET_SEARCH_HELP_VALUES( )`, which runs a DDIC search help
including its search-help exit and returns a flat result list. See the value-help example in
[`../DPC_EXT/METHODS/GetEntitySet.abap`](../DPC_EXT/METHODS/GetEntitySet.abap).

**2. Read the underlying tables yourself** and expose them as a `*ValueHelpSet` — usually
simpler and easier to page. The check/text tables are listed in
[`ValueHelpSources.md`](ValueHelpSources.md).

Either way, bind the result to the consuming property with a `ValueList` annotation in
`MPC_EXT`.

> **Authorization.** A search help does not carry the calling application's business
> authorization. Exposing one over OData makes its data reachable by anyone who can reach the
> service. This matters most for personnel and partner data — see the root README,
> *Security & Authorization Boundary*.

## Reference table

| Field(s) | Search Help | Description (EN) | Description (TR) |
|---|---|---|---|
| Auart | H_TVAK | Order Types | Sipariş Türleri |
| Aufnr | ORDEA | Order — Controlling Area & Order Group | Sipariş — Kontrol Alanı & Sipariş Grubu |
| Banfn | MBANA | Purchase Requisitions per Asset | Satınalma Talepleri — Duran Varlık |
| Bsart | H_T161 | Purchasing Document Type | Satınalma Belgesi Türü |
| Bukrs | H_T001 | Company Code | Şirket Kodu |
| Bu_Partner | BUPAP | Business Partner | İş Ortağı |
| Bzirk | H_T171 | Sales District | Satış Bölgesi |
| Charg | H_MCHA | Material & Plant & Batch | Malzeme & Üretim Yeri & Parti |
| Ebeln | MEKKA | Purchasing Documents per Asset | Satınalma Belgeleri — Duran Varlık |
| Ekgrp | H_T024 | Purchasing Group | Satınalma Grubu |
| Ekorg | H_T024E | Purchasing Organization | Satınalma Organizasyonu |
| Fkart | H_TVFK | Billing Type | Faturalama Türü |
| Gsber | H_TGSB | Business Area | İş Alanı |
| Katr1 | H_TVK1 | Customer Attribute 1 | Müşteri Niteliği 1 |
| Kdgrp | H_T151 | Customer Group | Müşteri Grubu |
| Ktgrd | H_TVKT | Account Assignment Group for Customer | Müşteri Hesap Tayin Grubu |
| Ktokd | H_T077D | Customer Account Group | Müşteri Hesap Grubu |
| Kunnr | DEBIA | Customer (by sales area) | Müşteri (satış alanına göre) |
| Kunnr | H_KNA1 | Customer from KNA1 (no plant restriction) | Müşteri (KNA1) |
| Lgort | H_T001L_ | Storage Location | Depo Yeri |
| Lgort, Werks | H_T001L_OLD | Storage Location per Plant | Üretim Yerine Göre Depo Yeri |
| Lifnr | KREDA | Vendor | Satıcı |
| Matkl | H_T023 | Material Group | Mal Grubu |
| Matnr | MAT0M | Material | Malzeme |
| Mbrsh | H_T137 | Industry Sector | Sektör |
| Mseh3, Msehi | H_T006 | Unit of Measure | Ölçü Birimi |
| Mtart | H_T134 | Material Type | Malzeme Türü |
| Pernr | EWAPERNR | Personnel Number (with name) | Personel Numarası (ad soyad ile) |
| Saknr, Hkont | SAKO_CORE | G/L Account | Ana Hesap |
| Spart, Vkorg | H_TVTA | Division per Sales Organization | Satış Organizasyonuna Göre Bölüm |
| Spras | H_T002 | Language Key | Dil Anahtarı |
| Vbeln | F4_VBAK | Sales Document | Satış Belgesi |
| Vkbur, Vkorg | H_TVKBZ / H_TVBUR | Sales Office | Satış Bürosu |
| Vkgrp, Vkbur | H_TVBVK | Sales Group per Sales Office | Satış Bürosuna Göre Satış Grubu |
| Vkorg | H_TVKO | Sales Organization | Satış Organizasyonu |
| Vkorg, Bukrs | FAGL_ELM_VKORG_BUKRS | Sales Organization with Company Code | Satış Organizasyonu + Şirket Kodu |
| Vtweg | H_TVTW | Distribution Channel | Dağıtım Kanalı |
| Vtweg, Vkorg | H_TVKOV | Distribution Channel per Sales Organization | Satış Organizasyonuna Göre Dağıtım Kanalı |
| Waers | FC_WAERS | Currency | Para Birimi |
| Werks | H_T001W | Plant | Üretim Yeri |
| Werks | H_NAME1 | Plant (by name) | Üretim Yeri (ada göre) |

Notes:

- Names beginning `H_` are typically SAP's help views over the corresponding check table.
- Collective search helps (e.g. `MAT0M`, `DEBIA`) contain several elementary search helps;
  which one applies depends on the calling context and on search-help exits.
- Result fields and search-help exits vary by release and by industry solution — **check the
  actual search help in `SE11` in your own system** before mapping its result list into entity
  properties.
- `Pernr` / `EWAPERNR` returns personal data. Treat it accordingly.

## Related

- [`ValueHelpSources.md`](ValueHelpSources.md) — underlying check and text tables
- [`../DPC_EXT/METHODS/GetEntitySet.abap`](../DPC_EXT/METHODS/GetEntitySet.abap) — `GET_SEARCH_HELP_VALUES( )` example
- [`../MPC_EXT/METHODS/UtilClass.abap`](../MPC_EXT/METHODS/UtilClass.abap) — `add_value_help( )`
