-- Auto-generated from joins-mysql.yaml (map@85230ed)
-- engine: mysql
-- view:   event_outbox_due

CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_event_outbox_due AS
SELECT
  eo.id,
  eo.event_type,
  eo.status,
  eo.attempts,
  eo.created_at,
  eo.next_attempt_at,
  TIMESTAMPDIFF(SECOND, eo.created_at, NOW()) AS age_sec,
  TIMESTAMPDIFF(SECOND, COALESCE(eo.next_attempt_at, eo.created_at), NOW()) AS since_next_sec
FROM event_outbox eo
WHERE eo.status IN ('pending','failed')
  AND (eo.next_attempt_at IS NULL OR eo.next_attempt_at <= NOW());

-- Auto-generated from joins-mysql.yaml (map@85230ed)
-- engine: mysql
-- view:   event_outbox_metrics

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


-- Auto-generated from joins-mysql.yaml (map@85230ed)
-- engine: mysql
-- view:   sync_backlog_by_node

CREATE OR REPLACE ALGORITHM=TEMPTABLE SQL SECURITY INVOKER VIEW vw_sync_backlog_by_node AS
SELECT
  COALESCE(producer_node, '(unknown)') AS producer_node,
  event_type,
  SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) AS pending,
  SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END)  AS failed,
  COUNT(*) AS total
FROM event_outbox
GROUP BY COALESCE(producer_node, '(unknown)'), event_type
ORDER BY pending DESC, failed DESC;


-- Auto-generated from joins-mysql.yaml (map@85230ed)
-- engine: mysql
-- view:   event_outbox_latency

CREATE OR REPLACE ALGORITHM=MERGE SQL SECURITY INVOKER VIEW vw_event_outbox_latency AS
SELECT
  ranked.event_type,
  ranked.processed,
  ranked.avg_latency_sec,
  ranked.max_latency_sec
FROM (
  SELECT
    eo.event_type,
    COUNT(*) OVER (PARTITION BY eo.event_type) AS processed,
    AVG(TIMESTAMPDIFF(SECOND, eo.created_at, eo.processed_at))
      OVER (PARTITION BY eo.event_type) AS avg_latency_sec,
    MAX(TIMESTAMPDIFF(SECOND, eo.created_at, eo.processed_at))
      OVER (PARTITION BY eo.event_type) AS max_latency_sec,
    ROW_NUMBER() OVER (PARTITION BY eo.event_type ORDER BY eo.event_type) AS rn
  FROM event_outbox eo
  WHERE eo.processed_at IS NOT NULL
) ranked
WHERE ranked.rn = 1;


-- Auto-generated from joins-mysql.yaml (map@85230ed)
-- engine: mysql
-- view:   event_throughput_hourly

CREATE OR REPLACE ALGORITHM=TEMPTABLE SQL SECURITY INVOKER VIEW vw_event_throughput_hourly AS
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
GROUP BY hour_ts;

