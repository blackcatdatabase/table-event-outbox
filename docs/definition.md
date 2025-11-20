<!-- Auto-generated from schema-map-postgres.psd1 @ 62c9c93 (2025-11-20T21:38:11+01:00) -->
# Definition – event_outbox

Outbox table for domain events waiting to be published downstream.

## Columns
| Column | Type | Null | Default | Description | Notes |
|-------:|:-----|:----:|:--------|:------------|:------|
| id | BIGINT | — | AS | Surrogate primary key. |  |
| event_key | CHAR(36) | NO | — | Event key / idempotency token. |  |
| entity_table | VARCHAR(64) | NO | — | Originating table. |  |
| entity_pk | VARCHAR(64) | NO | — | Primary key of the originating row. |  |
| event_type | VARCHAR(100) | NO | — | Event type string. |  |
| payload | JSONB | NO | — | JSON payload delivered to consumers. |  |
| status | TEXT | NO | 'pending' | Delivery status. | enum: pending, sent, failed |
| attempts | INTEGER | NO | 0 | Number of delivery attempts. |  |
| next_attempt_at | TIMESTAMPTZ(6) | YES | — | When the next attempt is scheduled. |  |
| processed_at | TIMESTAMPTZ(6) | YES | — | When processing completed. |  |
| producer_node | VARCHAR(100) | YES | — | Node that produced the event. |  |
| created_at | TIMESTAMPTZ(6) | NO | CURRENT_TIMESTAMP(6) | Creation timestamp (UTC). |  |