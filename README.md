# 📦 Event Outbox

> Auto-generated from [schema-map-postgres.yaml](https://github.com/blackcatacademy/blackcat-database/blob/main/scripts/schema/schema-map-postgres.yaml) (map@sha1:5221bb5c65d0fbe010594635f9efb6fc13c307b2). Do not edit manually.
> Targets: PHP 8.3; MySQL 8.x / MariaDB 10.4; Postgres 15+.

![PHP](https://img.shields.io/badge/PHP-8.3-blueviolet) ![DB](https://img.shields.io/badge/DB-MySQL%20%7C%20MariaDB%20%7C%20Postgres-informational) ![License](https://img.shields.io/badge/license-BlackCat%20Proprietary-red) ![Status](https://img.shields.io/badge/status-stable-success)

![Docs](https://img.shields.io/badge/Docs-ready-success) ![Changelog](https://img.shields.io/badge/Changelog-ok-success) ![Changelog%20freshness](https://img.shields.io/badge/Changelog%20freshness-fresh-success) ![Seeds](https://img.shields.io/badge/Seeds-missing-critical) ![Views](https://img.shields.io/badge/Views-ok-success) ![Lineage](https://img.shields.io/badge/Lineage-solo-critical) ![Drift](https://img.shields.io/badge/Drift-clean-success) ![Index%20coverage](https://img.shields.io/badge/Index%20coverage-ready-success) ![PII](https://img.shields.io/badge/PII-review-critical)

✅ No engine drift detected

<div style='margin:12px 0 18px;padding:14px 16px;border-radius:14px;background:linear-gradient(120deg,#0b1021 0%,#111827 40%,#312e81 100%);color:#e2e8f0;border:1px solid #1f2937;box-shadow:0 18px 55px rgba(49,46,129,0.35);'>
<div style='font-weight:700;letter-spacing:0.4px;font-size:14px;'>Schema vibe</div>
<div style='font-size:13px;opacity:0.95;'>Map: <a href='https://github.com/blackcatacademy/blackcat-database/blob/main/scripts/schema/schema-map-postgres.yaml' style='color:#a5b4fc;'>schema-map-postgres.yaml</a> · Docs: <a href='docs/definitions.md'>definitions</a> · Drift warnings: 0</div>
<div style='font-size:13px;opacity:0.92;'>Lineage heat: 0 outbound / 0 inbound · ✅ No engine drift detected · Index coverage: ready · PII: 3 · Changelog: fresh (18 d)</div>
</div>

## Quick Links
- Schema map: [schema-map-postgres.yaml](https://github.com/blackcatacademy/blackcat-database/blob/main/scripts/schema/schema-map-postgres.yaml)
- Pkg folder: [packages\event-outbox](https://github.com/blackcatacademy/blackcat-database/blob/main/packages\event-outbox)
- Definitions: [docs/definitions.md](docs/definitions.md)
- Engine differences: [docs/definitions.md#engine-differences](docs/definitions.md#engine-differences)
- Changelog: [CHANGELOG.md](CHANGELOG.md)

> ERD preview: auto-rendered from docs/definitions.md (no FK links detected; showing anchor).
```mermaid
graph LR
  %% Neon lineage view (auto-parsed from docs/definitions.md)
  classDef center fill:#0b1021,stroke:#ff6b6b,stroke-width:3px,color:#fefefe;
  classDef link fill:#0a1f33,stroke:#64dfdf,stroke-width:2px,color:#e8f7ff;
  classDef accent fill:#1d1b4c,stroke:#a855f7,stroke-width:2px,color:#f5e1ff;
  classDef inbound fill:#0f172a,stroke:#10b981,stroke-width:2px,color:#e2fcef;
  event_outbox["event_outbox"]:::center
```

## Contents
- [Quick Links](#quick-links)
- [At a Glance](#at-a-glance)
- [Summary](#summary)
- [Relationship Graph](#relationship-graph)
- [Engine Matrix](#engine-matrix)
- [Engine Drift](#engine-drift)
- [Constraints Snapshot](#constraints-snapshot)
- [Compliance Notes](#compliance-notes)
- [Schema Files](#schema-files)
- [Views](#views)
- [Seeds](#seeds)
- [Usage](#usage)
- [Quality Gates](#quality-gates)
- [Regeneration](#regeneration)

## At a Glance
| Metric | Count |
| --- | --- |
| Columns | 14 |
| Indexes | 6 |
| Foreign keys | 0 |
| Unique keys | 3 |
| Outbound links (FK targets) | 0 |
| Inbound links (tables depending on this) | 0 |
| Views | 14 |
| Seeds | 0 |
| Drift warnings | 0 |
| PII flags | 3 |

## Summary
- Table: event_outbox
- Schema files: 8
- Views: 4
- Seeds: 0
- Docs: present
- Changelog: present
- Changelog freshness: fresh (18 days old; threshold 45)
- Outbound FK targets: none
- Inbound FK sources: none (from definitions)
- Index coverage: ready
- Engine targets: PHP 8.3; MySQL/MariaDB/Postgres

## Relationship Graph
_No foreign keys declared in docs/definitions.md (inbound or outbound)._

## Engine Matrix
| Engine | Support |
| --- | --- |
| mysql | ✅ schema(4)<br/>✅ views(2)<br/>⚠️ seeds |
| postgres | ✅ schema(4)<br/>✅ views(2)<br/>⚠️ seeds |

## Engine Drift
_No engine differences detected._

## Constraints Snapshot
- `attempts` – default=0
- `created_at` – default=CURRENT_TIMESTAMP(6)
- `status` – default=pending, enum

## Schema Files
| File | Engine |
| --- | --- |
| [001_table.mysql.sql](schema/001_table.mysql.sql) | mysql |
| [001_table.postgres.sql](schema/001_table.postgres.sql) | postgres |
| [020_indexes.mysql.sql](schema/020_indexes.mysql.sql) | mysql |
| [020_indexes.postgres.sql](schema/020_indexes.postgres.sql) | postgres |
| [040_views_joins.mysql.sql](schema/040_views_joins.mysql.sql) | mysql |
| [040_views_joins.postgres.sql](schema/040_views_joins.postgres.sql) | postgres |
| [040_views.mysql.sql](schema/040_views.mysql.sql) | mysql |
| [040_views.postgres.sql](schema/040_views.postgres.sql) | postgres |

## Views
| File | Engine | Source |
| --- | --- | --- |
| [040_views_joins.mysql.sql](schema/040_views_joins.mysql.sql) | mysql | package |
| [040_views_joins.postgres.sql](schema/040_views_joins.postgres.sql) | postgres | package |
| [040_views.mysql.sql](schema/040_views.mysql.sql) | mysql | package |
| [040_views.postgres.sql](schema/040_views.postgres.sql) | postgres | package |

## Seeds
_No seed files found._

## Compliance Notes
> ⚠️ Potential PII/secret fields – review retention/encryption policies:
- entity_pk (key)
- event_key (token)
- id (key)

## Usage
- Install/upgrade schema: pwsh -NoLogo -NoProfile -File scripts/schema-tools/Migrate-DryRun.ps1 -Package event-outbox -Apply
- Split schema: pwsh -NoLogo -NoProfile -File scripts/schema-tools/Split-SchemaToPackages.ps1
- Generate PHP DTO/Repo: pwsh -NoLogo -NoProfile -File scripts/schema-tools/Generate-PhpFromSchema.ps1 -SchemaDir scripts/schema -TemplatesRoot scripts/templates/php -ModulesRoot packages -NameResolution detect -Force
- Validate SQL: pwsh -NoLogo -NoProfile -File scripts/schema-tools/Lint-Sql.ps1 -PackagesDir packages
- PHPUnit (full DB matrix): set BC_DB=mysql|postgres|mariadb then run `vendor/bin/phpunit --configuration tests/phpunit.xml.dist --testsuite "DB Integration"`

## Quality Gates
[x] Definitions present
[x] Changelog present
[x] Changelog fresh
[x] Index coverage (PK + index)
[ ] Outbound lineage captured
[ ] Inbound lineage mapped
[x] ERD renderable (mermaid)
[ ] Seeds available – add smoke data seeds

## Maintenance Checklist
- [ ] Update schema map and split: Split-SchemaToPackages.ps1
- [ ] Regenerate PHP DTO/Repo: Generate-PhpFromSchema.ps1
- [ ] Rebuild definitions + README + docs index
- [ ] Lint SQL + run full PHPUnit DB matrix

## Regeneration
- Definitions: pwsh -NoLogo -NoProfile -File scripts/schema-tools/Build-Definitions.ps1 -Force
- Pkg README: pwsh -NoLogo -NoProfile -File scripts/docs/New-PackageReadmes.ps1 -Force
- Docs index: pwsh -NoLogo -NoProfile -File scripts/docs/New-DocsIndex.ps1 -Force
- Pkg changelog: pwsh -NoLogo -NoProfile -File scripts/docs/New-PackageChangelogs.ps1 -Force

---
Generated by scripts/docs/New-PackageReadmes.ps1 (map@sha1:5221bb5c65d0fbe010594635f9efb6fc13c307b2)
⚖️ License: Proprietary – see [LICENSE](https://github.com/blackcatacademy/blackcat-database/blob/main/LICENSE).
