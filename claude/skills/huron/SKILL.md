---
name: huron
description: Query Huron data via the Trino CLI. Use when the user asks to query Huron, Trino, metrics, core app logs, or when investigating data in huron_iceberg or coreapplogs catalogs.
user-invocable: true
allowed-tools: Bash(huron *)
---

# Querying Huron data via Trino

The `huron` shell function connects to Trino clusters for querying Huron data.

## Usage

```
huron [CLUSTER] [--schema catalog.schema] [--llm]
```

### Clusters (positional, default: prod-gateway)

Gateway clusters use mTLS cert auth:
- `prod-gateway` (default)
- `staging-gateway`
- `dev-gateway`

MTRC clusters use password auth (prompts or reads `$HURON_MTRC_PASSWORD`):
- `prod-mtrc`
- `staging-mtrc`
- `dev-mtrc`

### Flags

- `--schema catalog.schema` — set catalog and schema (default: `huron_iceberg.metrics`)
- `--llm` — output as CSV for machine-parseable results

### Common catalog.schema values

| catalog.schema | content |
|---|---|
| `huron_iceberg.metrics` | metrics (default) |
| `huron_iceberg.metrics_data` | metrics data |
| `huron_iceberg.huron_user_data` | user data |
| `huron_iceberg.huron_user_data_long_term` | long-term user data |
| `huron_iceberg.staging` | staging data |
| `coreapplogs.coreapplogs_tokenized` | tokenized core app logs |
| `coreapplogs.huron_user_data` | user data via coreapplogs |

## Running queries non-interactively

Always use `--llm` when running queries for analysis. Pass SQL via `--execute`:

```bash
huron --llm --execute "SELECT * FROM some_table LIMIT 10"
```

With a different schema:

```bash
huron --llm --schema huron_iceberg.huron_user_data --execute "SELECT * FROM some_table LIMIT 10"
```

Against a different cluster:

```bash
huron staging-gateway --llm --schema coreapplogs.coreapplogs_tokenized --execute "SELECT * FROM some_table LIMIT 10"
```

## When to use this

- The user asks to check or query Huron/Trino data
- You need to inspect metrics, user data, or core app logs to investigate an issue
- A file or conversation references Huron tables and the user suggests running a query
- Default to prod-gateway unless the user specifies otherwise
