-- Auto-generated from joins-postgres.yaml (map@94ebe6c)
-- engine: postgres
-- view:   event_outbox_metrics

-- Aggregated metrics for [event_outbox]
CREATE OR REPLACE VIEW vw_event_outbox_metrics AS
SELECT
  event_type,
  COUNT(*)                                AS total,
  COUNT(*) FILTER (WHERE status='pending') AS pending,
  COUNT(*) FILTER (WHERE status='sent')    AS sent,
  COUNT(*) FILTER (WHERE status='failed')  AS failed,
  AVG(EXTRACT(EPOCH FROM (now() - created_at))) AS avg_created_lag_sec,
  PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (now()-created_at))) AS p50_created_lag_sec,
  PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (now()-created_at))) AS p95_created_lag_sec,
  AVG(attempts)                           AS avg_attempts,
  MAX(attempts)                           AS max_attempts,
  COUNT(*) FILTER (WHERE status IN ('pending','failed') AND (next_attempt_at IS NULL OR next_attempt_at <= now())) AS due_now
FROM event_outbox
GROUP BY event_type;

-- Auto-generated from joins-postgres.yaml (map@94ebe6c)
-- engine: postgres
-- view:   event_outbox_due

-- Pending/due outbox messages with lag
CREATE OR REPLACE VIEW vw_event_outbox_due AS
SELECT
  eo.id,
  eo.event_type,
  eo.status,
  eo.attempts,
  eo.created_at,
  eo.next_attempt_at,
  EXTRACT(EPOCH FROM (now() - eo.created_at)) AS age_sec,
  EXTRACT(EPOCH FROM (now() - COALESCE(eo.next_attempt_at, eo.created_at))) AS since_next_sec
FROM event_outbox eo
WHERE eo.status IN ($$pending$$,$$failed$$)
  AND (eo.next_attempt_at IS NULL OR eo.next_attempt_at <= now());


-- Auto-generated from joins-postgres.yaml (map@94ebe6c)
-- engine: postgres
-- view:   event_outbox_throughput_hourly

-- Hourly throughput for outbox/inbox
CREATE OR REPLACE VIEW vw_event_throughput_hourly AS
WITH o AS (
  SELECT date_trunc('hour', created_at) AS ts, COUNT(*) AS outbox_cnt
  FROM event_outbox GROUP BY 1
),
i AS (
  SELECT date_trunc('hour', received_at) AS ts, COUNT(*) AS inbox_cnt
  FROM event_inbox GROUP BY 1
)
SELECT
  COALESCE(o.ts, i.ts) AS hour_ts,
  COALESCE(outbox_cnt,0) AS outbox_cnt,
  COALESCE(inbox_cnt,0)  AS inbox_cnt
FROM o FULL JOIN i ON o.ts = i.ts
ORDER BY hour_ts DESC;


-- Auto-generated from joins-postgres.yaml (map@94ebe6c)
-- engine: postgres
-- view:   event_outbox_latency

-- Processing latency (created -> processed) by type
CREATE OR REPLACE VIEW vw_event_outbox_latency AS
SELECT DISTINCT ON (event_type)
  event_type,
  processed,
  avg_latency_sec,
  max_latency_sec
FROM (
  SELECT
    event_type,
    COUNT(*) OVER (PARTITION BY event_type)                                        AS processed,
    AVG(EXTRACT(EPOCH FROM (processed_at - created_at)))
      OVER (PARTITION BY event_type)                                               AS avg_latency_sec,
    MAX(EXTRACT(EPOCH FROM (processed_at - created_at)))
      OVER (PARTITION BY event_type)                                               AS max_latency_sec,
    ROW_NUMBER() OVER (PARTITION BY event_type ORDER BY event_type)                AS rn
  FROM event_outbox
  WHERE processed_at IS NOT NULL
) ranked
WHERE rn = 1;


-- Auto-generated from joins-postgres.yaml (map@94ebe6c)
-- engine: postgres
-- view:   event_outbox_backlog_by_node

-- Pending outbox backlog per producer node/channel
CREATE OR REPLACE VIEW vw_sync_backlog_by_node AS
SELECT
  COALESCE(producer_node, $$(unknown)$$) AS producer_node,
  event_type,
  COUNT(*) FILTER (WHERE status = $$pending$$) AS pending,
  COUNT(*) FILTER (WHERE status = $$failed$$)  AS failed,
  COUNT(*) AS total
FROM event_outbox
GROUP BY COALESCE(producer_node, $$(unknown)$$), event_type
ORDER BY pending DESC NULLS LAST, failed DESC;

