# `$batch` — OData V2 Batch Requests (SAP Gateway)

`$batch` lets a client send several OData operations in **one** HTTP request. SAP Gateway
serves it at the service root:

```
POST /sap/opu/odata/sap/EXAMPLE_SRV/$batch
```

Fiori/UI5 clients use it constantly — `sap.ui.model.odata.v2.ODataModel` batches reads and
changes automatically unless batching is explicitly disabled.

## Why it matters

- **Fewer round trips.** A list view plus three value-help reads becomes one request.
- **Atomic changes.** Modifying operations grouped in a *changeset* are meant to be
  committed or rejected together — see [Changesets and the SAP LUW](#changesets-and-the-sap-luw).
- **It changes how your DPC_EXT code is called.** Your methods are invoked once per
  operation inside the batch, in the same work process, within one Gateway request.

## Structure

A `$batch` body is a MIME multipart document.

- The **outer** multipart (`multipart/mixed; boundary=batch_<id>`) holds *batch parts*.
- A batch part is either a single **retrieve** operation (`GET`) or a **changeset**.
- A **changeset** is a nested multipart (`multipart/mixed; boundary=changeset_<id>`)
  containing one or more **modifying** operations (`POST` / `PUT` / `MERGE` / `DELETE`).
- `GET` operations must **not** appear inside a changeset.

## Request example

Generic values only — adapt the service name, entity sets and fields to your own service.

```http
POST /sap/opu/odata/sap/EXAMPLE_SRV/$batch HTTP/1.1
Host: example.sap.system:44300
Content-Type: multipart/mixed; boundary=batch_example
X-CSRF-Token: <token fetched with X-CSRF-Token: Fetch>
Accept: multipart/mixed

--batch_example
Content-Type: application/http
Content-Transfer-Encoding: binary

GET ExampleSet?$skip=0&$top=20&$select=Key,Description,CreatedOn&$inlinecount=allpages HTTP/1.1
Accept: application/json

--batch_example
Content-Type: multipart/mixed; boundary=changeset_example

--changeset_example
Content-Type: application/http
Content-Transfer-Encoding: binary
Content-ID: 1

POST ExampleSet HTTP/1.1
Content-Type: application/json

{"Key":"","Description":"New entry"}

--changeset_example
Content-Type: application/http
Content-Transfer-Encoding: binary
Content-ID: 2

MERGE ExampleSet('0000000001') HTTP/1.1
Content-Type: application/json

{"Description":"Changed entry"}

--changeset_example--

--batch_example--
```

Notes on the example:

- **`X-CSRF-Token` is required** for `$batch`, because `$batch` is a `POST`. Fetch it first
  with a `GET` carrying `X-CSRF-Token: Fetch`, then send it back on the batch request.
- The `GET` part sits **outside** the changeset; the two modifying operations sit inside it.
- `Content-ID` identifies an operation within a changeset and allows later operations to
  reference a preceding one (`$1`).
- Each inner request line is a **relative** URI — no leading slash, no service root.
- A blank line separates each part's MIME headers from the embedded HTTP request, and the
  embedded request's headers from its body. Those blank lines are significant.

## Response

The response mirrors the structure: `multipart/mixed` with one part per operation, each
containing a full HTTP response (status line, headers, body).

```http
HTTP/1.1 202 Accepted
Content-Type: multipart/mixed; boundary=batchresponse_example

--batchresponse_example
Content-Type: application/http
Content-Transfer-Encoding: binary

HTTP/1.1 200 OK
Content-Type: application/json

{"d":{"results":[ ... ],"__count":"137"}}
...
```

**The outer `202 Accepted` says nothing about whether the individual operations succeeded.**
Each part carries its own status code, and a client must inspect them individually. This is
the most common `$batch` mistake on the client side.

## Changesets and the SAP LUW

A changeset is the point where `$batch` meets ABAP transaction handling, and it is the
reason the guidance in the root README's *Transaction Handling (SAP LUW)* section matters:

- All operations in a changeset run in **one Gateway request and one work process**.
- The changeset is meant to be **atomic** — all of its operations succeed, or none is
  persisted.
- If a DPC_EXT method **commits during the changeset**, the framework can no longer discard
  the earlier operations, and atomicity is lost. This is why the examples in this repository
  never commit before validating the business return table.
- `/IWBEP/IF_MGW_APPL_SRV_RUNTIME` exposes changeset lifecycle methods
  (`CHANGESET_BEGIN` / `CHANGESET_END` / `CHANGESET_PROCESS`) intended for owning the
  transaction across a whole changeset rather than per operation.

> The exact changeset lifecycle contract — which methods the framework calls, in what order,
> and what it does on failure — is release-specific. **NEEDS OFFICIAL VERIFICATION** against
> your SAP_GWFND release before relying on a particular behaviour.

## Testing

- `/IWFND/GW_CLIENT` — has a dedicated multipart/batch mode.
- Browser dev tools — UI5 applications issue `$batch` continuously; the request/response
  bodies are readable directly in the network tab.

## Related

- [Transaction handling](../README.md#transaction-handling-sap-luw)
- [OData V2 URI reference](../ODATA/README.md)
- [Gateway error handling](../DPC_EXT/METHODS/Exception.abap)
