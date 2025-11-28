-- Auto-generated from schema-views-mysql.psd1 (map@mtime:2025-11-27T15:35:35Z)
-- engine: mysql
-- table:  event_outbox

-- Contract view for [event_outbox]
-- Adds helpers: is_pending, is_due.
CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_event_outbox AS
SELECT
  id,
  event_key,
  entity_table,
  entity_pk,
  event_type,
  payload,
  status,
  attempts,
  next_attempt_at,
  processed_at,
  producer_node,
  created_at,
  (status = 'pending') AS is_pending,
  (status = 'pending' AND (next_attempt_at IS NULL OR next_attempt_at <= NOW())) AS is_due
FROM event_outbox;
