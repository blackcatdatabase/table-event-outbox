-- Auto-generated from schema-map-mysql.yaml (map@sha1:7AAC4013A2623AC60C658C9BF8458EFE0C7AB741)
-- engine: mysql
-- table:  event_outbox

CREATE INDEX idx_event_outbox_status_sched ON event_outbox (status, next_attempt_at);

CREATE INDEX idx_event_outbox_entity_time ON event_outbox (entity_table, entity_pk, created_at);

CREATE INDEX idx_event_outbox_created_at ON event_outbox (created_at);
