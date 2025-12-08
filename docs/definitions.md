# event_outbox

Outbox table for domain events waiting to be published downstream.

## Columns
| Column | Type | Null | Default | Description |
| --- | --- | --- | --- | --- |
| attempts | INTEGER | NO | 0 | Number of delivery attempts. |
| created_at | TIMESTAMPTZ(6) | NO | CURRENT_TIMESTAMP(6) | Creation timestamp (UTC). |
| entity_pk | VARCHAR(64) | NO |  | Primary key of the originating row. |
| entity_table | VARCHAR(64) | NO |  | Originating table. |
| event_key | CHAR(36) | NO |  | Event key / idempotency token. |
| event_type | VARCHAR(100) | NO |  | Event type string. |
| id | BIGINT | NO |  | Surrogate primary key. |
| next_attempt_at | TIMESTAMPTZ(6) | YES |  | When the next attempt is scheduled. |
| payload | JSONB | NO |  | JSON payload delivered to consumers. |
| processed_at | TIMESTAMPTZ(6) | YES |  | When processing completed. |
| producer_node | VARCHAR(100) | YES |  | Node that produced the event. |
| status | TEXT | NO | pending | Delivery status. (enum: pending, sent, failed) |

## Engine Details

### mysql

Unique keys:
| Name | Columns |
| --- | --- |
| uq_event_outbox_key | event_key |

Indexes:
| Name | Columns | SQL |
| --- | --- | --- |
| idx_event_outbox_created_at | created_at | CREATE INDEX idx_event_outbox_created_at ON event_outbox (created_at) |
| idx_event_outbox_entity_time | entity_table,entity_pk,created_at | CREATE INDEX idx_event_outbox_entity_time ON event_outbox (entity_table, entity_pk, created_at) |
| idx_event_outbox_status_sched | status,next_attempt_at | CREATE INDEX idx_event_outbox_status_sched ON event_outbox (status, next_attempt_at) |
| uq_event_outbox_key | event_key | UNIQUE KEY uq_event_outbox_key (event_key) |

### postgres

Unique keys:
| Name | Columns |
| --- | --- |
| uq_event_outbox_key | event_key |

Indexes:
| Name | Columns | SQL |
| --- | --- | --- |
| gin_event_outbox_payload | payloadjsonb_path_ops | CREATE INDEX IF NOT EXISTS gin_event_outbox_payload ON event_outbox USING GIN (payload jsonb_path_ops) |
| idx_event_outbox_created_at | created_at | CREATE INDEX IF NOT EXISTS idx_event_outbox_created_at ON event_outbox (created_at) |
| idx_event_outbox_entity_time | entity_table,entity_pk,created_at | CREATE INDEX IF NOT EXISTS idx_event_outbox_entity_time ON event_outbox (entity_table, entity_pk, created_at) |
| idx_event_outbox_status_sched | status,next_attempt_at | CREATE INDEX IF NOT EXISTS idx_event_outbox_status_sched ON event_outbox (status, next_attempt_at) |
| uq_event_outbox_key | event_key | CONSTRAINT uq_event_outbox_key UNIQUE (event_key) |

## Engine differences

## Views
| View | Engine | Flags | File |
| --- | --- | --- | --- |
| vw_event_outbox | mysql | algorithm=MERGE, security=INVOKER | [packages\event-outbox\schema\040_views.mysql.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views.mysql.sql) |
| vw_event_outbox_due | mysql | algorithm=MERGE, security=INVOKER | [packages\event-outbox\schema\040_views_joins.mysql.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.mysql.sql) |
| vw_event_outbox_latency | mysql | algorithm=MERGE, security=INVOKER | [packages\event-outbox\schema\040_views_joins.mysql.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.mysql.sql) |
| vw_event_outbox_metrics | mysql | algorithm=MERGE, security=INVOKER | [packages\event-outbox\schema\040_views_joins.mysql.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.mysql.sql) |
| vw_event_throughput_hourly | mysql | algorithm=MERGE, security=INVOKER | [packages\event-outbox\schema\040_views_joins.mysql.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.mysql.sql) |
| vw_sync_backlog_by_node | mysql | algorithm=MERGE, security=INVOKER | [packages\event-outbox\schema\040_views_joins.mysql.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.mysql.sql) |
| vw_event_outbox | postgres |  | [packages\event-outbox\schema\040_views.postgres.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views.postgres.sql) |
| vw_event_outbox_due | postgres |  | [packages\event-outbox\schema\040_views_joins.postgres.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.postgres.sql) |
| vw_event_outbox_latency | postgres |  | [packages\event-outbox\schema\040_views_joins.postgres.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.postgres.sql) |
| vw_event_outbox_metrics | postgres |  | [packages\event-outbox\schema\040_views_joins.postgres.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.postgres.sql) |
| vw_event_throughput_hourly | postgres |  | [packages\event-outbox\schema\040_views_joins.postgres.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.postgres.sql) |
| vw_sync_backlog_by_node | postgres |  | [packages\event-outbox\schema\040_views_joins.postgres.sql](https://github.com/blackcatacademy/blackcat-database/packages/event-outbox/schema/040_views_joins.postgres.sql) |
