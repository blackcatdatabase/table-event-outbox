-- Auto-generated from schema-map-postgres.yaml (map@sha1:6D9B52237D942B2B3855FD0F5500331B935A7C62)
-- engine: postgres
-- table:  event_outbox

CREATE INDEX IF NOT EXISTS idx_event_outbox_status_sched ON event_outbox (status, next_attempt_at);

CREATE INDEX IF NOT EXISTS idx_event_outbox_entity_time ON event_outbox (entity_table, entity_pk, created_at);

CREATE INDEX IF NOT EXISTS idx_event_outbox_created_at ON event_outbox (created_at);

CREATE INDEX IF NOT EXISTS gin_event_outbox_payload ON event_outbox USING GIN (payload jsonb_path_ops);
