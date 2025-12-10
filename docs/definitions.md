# event_outbox

Outbox table for domain events waiting to be published downstream.

## Columns
| Column | Type | Null | Default | Description |
| --- | --- | --- | --- | --- |
| created_at | mysql: DATETIME(6) / postgres: TIMESTAMPTZ(6) | NO | CURRENT_TIMESTAMP(6) | Creation timestamp (UTC). |
| id | BIGINT | NO |  | Surrogate primary key. |
| attempts | mysql: INT / postgres: INTEGER | NO | 0 | Number of delivery attempts. |
| status | mysql: ENUM('pending','sent','failed') / postgres: TEXT | NO | pending | Delivery status. (enum: pending, sent, failed) |
| entity_table | VARCHAR(64) | NO |  | Originating table. |
| next_attempt_at | mysql: DATETIME(6) / postgres: TIMESTAMPTZ(6) | YES |  | When the next attempt is scheduled. |
| event_key | CHAR(36) | NO |  | Event key / idempotency token. |
| processed_at | mysql: DATETIME(6) / postgres: TIMESTAMPTZ(6) | YES |  | When processing completed. |
| payload | mysql: JSON / postgres: JSONB | NO |  | JSON payload delivered to consumers. |
| event_type | VARCHAR(100) | NO |  | Event type string. |
| producer_node | VARCHAR(100) | YES |  | Node that produced the event. |
| entity_pk | VARCHAR(64) | NO |  | Primary key of the originating row. |

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
| vw_event_outbox | mysql | algorithm=MERGE, security=INVOKER | [../schema/040_views.mysql.sql](../schema/040_views.mysql.sql) |
| vw_event_outbox_due | mysql | algorithm=MERGE, security=INVOKER | [../schema/040_views_joins.mysql.sql](../schema/040_views_joins.mysql.sql) |
| vw_event_outbox_latency | mysql | algorithm=MERGE, security=INVOKER | [../schema/040_views_joins.mysql.sql](../schema/040_views_joins.mysql.sql) |
| vw_event_outbox_metrics | mysql | algorithm=MERGE, security=INVOKER | [../schema/040_views_joins.mysql.sql](../schema/040_views_joins.mysql.sql) |
| vw_event_throughput_hourly | mysql | algorithm=MERGE, security=INVOKER | [../schema/040_views_joins.mysql.sql](../schema/040_views_joins.mysql.sql) |
| vw_sync_backlog_by_node | mysql | algorithm=MERGE, security=INVOKER | [../schema/040_views_joins.mysql.sql](../schema/040_views_joins.mysql.sql) |
| vw_event_outbox | postgres |  | [../schema/040_views.postgres.sql](../schema/040_views.postgres.sql) |
| vw_event_outbox_due | postgres |  | [../schema/040_views_joins.postgres.sql](../schema/040_views_joins.postgres.sql) |
| vw_event_outbox_latency | postgres |  | [../schema/040_views_joins.postgres.sql](../schema/040_views_joins.postgres.sql) |
| vw_event_outbox_metrics | postgres |  | [../schema/040_views_joins.postgres.sql](../schema/040_views_joins.postgres.sql) |
| vw_event_throughput_hourly | postgres |  | [../schema/040_views_joins.postgres.sql](../schema/040_views_joins.postgres.sql) |
| vw_sync_backlog_by_node | postgres |  | [../schema/040_views_joins.postgres.sql](../schema/040_views_joins.postgres.sql) |
