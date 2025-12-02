-- Auto-generated from schema-map-postgres.yaml (map@94ebe6c)
-- engine: postgres
-- table:  event_outbox

CREATE INDEX IF NOT EXISTS idx_event_outbox_status_sched ON event_outbox (status, next_attempt_at);

CREATE INDEX IF NOT EXISTS idx_event_outbox_entity_time ON event_outbox (entity_table, entity_pk, created_at);

CREATE INDEX IF NOT EXISTS idx_event_outbox_created_at ON event_outbox (created_at);

CREATE INDEX IF NOT EXISTS gin_event_outbox_payload ON event_outbox USING GIN (payload jsonb_path_ops);
