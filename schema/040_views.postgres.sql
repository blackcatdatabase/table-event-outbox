-- Auto-generated from schema-views-postgres.psd1 (map@62c9c93)
-- engine: postgres
-- table:  event_outbox_metrics
-- Aggregated metrics for [event_outbox]
CREATE OR REPLACE VIEW vw_event_outbox_metrics AS
SELECT
  event_type,
  COUNT(*)                                AS total,
  COUNT(*) FILTER (WHERE status=''pending'') AS pending,
  COUNT(*) FILTER (WHERE status=''sent'')    AS sent,
  COUNT(*) FILTER (WHERE status=''failed'')  AS failed,
  AVG(EXTRACT(EPOCH FROM (now() - created_at)))                                   AS avg_created_lag_sec,
  PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (now()-created_at))) AS p50_created_lag_sec,
  PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (now()-created_at))) AS p95_created_lag_sec,
  AVG(attempts)                           AS avg_attempts,
  MAX(attempts)                           AS max_attempts,
  COUNT(*) FILTER (WHERE status IN (''pending'',''failed'') AND (next_attempt_at IS NULL OR next_attempt_at <= now())) AS due_now
FROM event_outbox
GROUP BY event_type;

-- Auto-generated from schema-views-postgres.psd1 (map@62c9c93)
-- engine: postgres
-- table:  event_outbox_throughput_hourly
-- Hourly throughput for outbox/inbox
CREATE OR REPLACE VIEW vw_event_throughput_hourly AS
WITH o AS (
  SELECT date_trunc(''hour'', created_at) AS ts, COUNT(*) AS outbox_cnt
  FROM event_outbox GROUP BY 1
),
i AS (
  SELECT date_trunc(''hour'', received_at) AS ts, COUNT(*) AS inbox_cnt
  FROM event_inbox GROUP BY 1
)
SELECT
  COALESCE(o.ts, i.ts) AS hour_ts,
  COALESCE(outbox_cnt,0) AS outbox_cnt,
  COALESCE(inbox_cnt,0)  AS inbox_cnt
FROM o FULL JOIN i ON o.ts = i.ts
ORDER BY hour_ts DESC;


-- Auto-generated from schema-views-postgres.psd1 (map@62c9c93)
-- engine: postgres
-- table:  event_outbox_latency
-- Processing latency (created -> processed) by type
CREATE OR REPLACE VIEW vw_event_outbox_latency AS
SELECT
  event_type,
  COUNT(*)                                                                 AS processed,
  AVG(EXTRACT(EPOCH FROM (processed_at - created_at)))                      AS avg_latency_sec,
  PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (processed_at - created_at))) AS p50_latency_sec,
  PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (processed_at - created_at))) AS p95_latency_sec,
  MAX(EXTRACT(EPOCH FROM (processed_at - created_at)))                      AS max_latency_sec
FROM event_outbox
WHERE processed_at IS NOT NULL
GROUP BY event_type;


-- Auto-generated from schema-views-postgres.psd1 (map@62c9c93)
-- engine: postgres
-- table:  event_outbox
-- Contract view for [event_outbox]
-- Adds helpers: is_pending, is_due.
CREATE OR REPLACE VIEW vw_event_outbox AS
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
  (status = ''pending'') AS is_pending,
  (status = ''pending'' AND (next_attempt_at IS NULL OR next_attempt_at <= now())) AS is_due
FROM event_outbox;


-- Auto-generated from schema-views-postgres.psd1 (map@62c9c93)
-- engine: postgres
-- table:  event_outbox_backlog_by_node
-- Pending outbox backlog per producer node/channel
CREATE OR REPLACE VIEW vw_sync_backlog_by_node AS
SELECT
  COALESCE(producer_node, ''(unknown)'') AS producer_node,
  event_type,
  COUNT(*) FILTER (WHERE status=''pending'') AS pending,
  COUNT(*) FILTER (WHERE status=''failed'')  AS failed,
  COUNT(*) AS total
FROM event_outbox
GROUP BY COALESCE(producer_node, ''(unknown)''), event_type
ORDER BY pending DESC NULLS LAST, failed DESC;

