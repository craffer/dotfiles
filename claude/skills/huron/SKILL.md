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
huron [CLUSTER] [--schema catalog.schema] [--execute "SQL"] [--llm]
```

### Clusters (positional, default: `prod-gateway`)

Gateway clusters — cert auth, no password needed:
- `prod-gateway` (default)
- `staging-gateway`
- `dev-gateway`

MTRC clusters — password auth (reads `$HURON_MTRC_PASSWORD` or prompts):
- `prod-mtrc`
- `staging-mtrc`
- `dev-mtrc`

### Flags

| Flag | Description |
|---|---|
| `--execute "SQL"` | Run a query non-interactively. Implies `--llm`. **Use this for all programmatic queries.** |
| `--schema catalog.schema` | Set catalog and schema (default: `huron_iceberg.metrics`) |
| `--llm` | Output as CSV — compact, with headers. Implied by `--execute`. |

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

## How to run queries (as Claude)

Always use `--execute` — it handles CSV output automatically. Never open interactive mode.

```bash
# Basic query (prod gateway, default schema)
huron --execute "SELECT * FROM some_table LIMIT 10"

# Different schema
huron --execute "SELECT * FROM some_table LIMIT 10" --schema huron_iceberg.huron_user_data

# Different cluster
huron staging-gateway --execute "SELECT * FROM some_table LIMIT 10"

# Explore available tables
huron --execute "SHOW TABLES"

# Describe a table
huron --execute "DESCRIBE some_table"
```

## When to use this

- The user asks to check or query Huron/Trino data
- You need to inspect metrics, user data, or core app logs to investigate an issue
- A file or conversation references Huron tables and the user suggests running a query
- Default to `prod-gateway` and `huron_iceberg.metrics` unless the user specifies otherwise
