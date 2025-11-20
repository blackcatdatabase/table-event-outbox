-- Auto-generated from schema-views-mysql.psd1 (map@db2f8b8)
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

-- Auto-generated from schema-views-mysql.psd1 (map@db2f8b8)
-- engine: mysql
-- table:  event_outbox_metrics
-- Aggregated metrics for [event_outbox]
CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_event_outbox_metrics AS
WITH base AS (
  SELECT
    event_type,
    COUNT(*) AS total,
    SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN status = 'sent'     THEN 1 ELSE 0 END) AS sent,
    SUM(CASE WHEN status = 'failed'   THEN 1 ELSE 0 END) AS failed,
    AVG(TIMESTAMPDIFF(SECOND, created_at, NOW())) AS avg_created_lag_sec,
    AVG(attempts) AS avg_attempts,
    MAX(attempts) AS max_attempts,
    SUM(CASE WHEN status IN ('pending','failed') AND (next_attempt_at IS NULL OR next_attempt_at <= NOW())
             THEN 1 ELSE 0 END) AS due_now
  FROM event_outbox
  GROUP BY event_type
),
ranked AS (
  SELECT
    event_type,
    TIMESTAMPDIFF(SECOND, created_at, NOW()) AS lag_sec,
    ROW_NUMBER() OVER (PARTITION BY event_type ORDER BY TIMESTAMPDIFF(SECOND, created_at, NOW())) AS rn,
    COUNT(*) OVER (PARTITION BY event_type) AS cnt
  FROM event_outbox
),
pcts AS (
  SELECT
    event_type,
    MAX(CASE WHEN rn = CEIL(0.50 * cnt) THEN lag_sec END) AS p50_created_lag_sec,
    MAX(CASE WHEN rn = CEIL(0.95 * cnt) THEN lag_sec END) AS p95_created_lag_sec
  FROM ranked
  GROUP BY event_type
)
SELECT
  b.event_type,
  b.total,
  b.pending,
  b.sent,
  b.failed,
  b.avg_created_lag_sec,
  p.p50_created_lag_sec,
  p.p95_created_lag_sec,
  b.avg_attempts,
  b.max_attempts,
  b.due_now
FROM base b
LEFT JOIN pcts p ON p.event_type = b.event_type;


-- Auto-generated from schema-views-mysql.psd1 (map@db2f8b8)
-- engine: mysql
-- table:  event_outbox_backlog_by_node
-- Pending outbox backlog per producer node/channel
CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_sync_backlog_by_node AS
SELECT
  COALESCE(producer_node, '(unknown)') AS producer_node,
  event_type,
  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END)  AS failed,
  COUNT(*) AS total
FROM event_outbox
GROUP BY COALESCE(producer_node, '(unknown)'), event_type
ORDER BY pending DESC, failed DESC;


-- Auto-generated from schema-views-mysql.psd1 (map@db2f8b8)
-- engine: mysql
-- table:  event_outbox_latency
-- Processing latency (created -> processed) by type
CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_event_outbox_latency AS
WITH latencies AS (
  SELECT
    event_type,
    TIMESTAMPDIFF(SECOND, created_at, processed_at) AS latency_sec
  FROM event_outbox
  WHERE processed_at IS NOT NULL
),
ranked AS (
  SELECT
    event_type,
    latency_sec,
    ROW_NUMBER() OVER (PARTITION BY event_type ORDER BY latency_sec) AS rn,
    COUNT(*) OVER (PARTITION BY event_type) AS cnt
  FROM latencies
)
SELECT
  event_type,
  COUNT(*) AS processed,
  AVG(latency_sec) AS avg_latency_sec,
  MAX(latency_sec) AS max_latency_sec,
  MAX(CASE WHEN rn = CEIL(0.50 * cnt) THEN latency_sec END) AS p50_latency_sec,
  MAX(CASE WHEN rn = CEIL(0.95 * cnt) THEN latency_sec END) AS p95_latency_sec
FROM ranked
GROUP BY event_type;


-- Auto-generated from schema-views-mysql.psd1 (map@db2f8b8)
-- engine: mysql
-- table:  event_outbox_throughput_hourly
-- Hourly throughput for outbox/inbox
CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_event_throughput_hourly AS
SELECT
  hour_ts,
  SUM(outbox_cnt) AS outbox_cnt,
  SUM(inbox_cnt)  AS inbox_cnt
FROM (
  SELECT
    DATE_FORMAT(created_at, '%Y-%m-%d %H:00:00') AS hour_ts,
    COUNT(*) AS outbox_cnt,
    0 AS inbox_cnt
  FROM event_outbox
  GROUP BY hour_ts
  UNION ALL
  SELECT
    DATE_FORMAT(received_at, '%Y-%m-%d %H:00:00') AS hour_ts,
    0 AS outbox_cnt,
    COUNT(*) AS inbox_cnt
  FROM event_inbox
  GROUP BY hour_ts
) t
GROUP BY hour_ts
ORDER BY hour_ts DESC;

