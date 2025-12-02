<?php
declare(strict_types=1);

namespace BlackCat\Database\Packages\EventOutbox;

use BlackCat\Database\SqlDialect;
use BlackCat\Database\Contracts\ModuleInterface;
use BlackCat\Database\Support\SqlIdentifier;
use BlackCat\Database\Support\SqlDirectoryRunner;
use BlackCat\Database\Support\SchemaIntrospector;
use BlackCat\Core\Database as Database;

final class EventOutboxModule implements ModuleInterface
{
    public function name(): string { return 'table-event_outbox'; }
    public function table(): string { return 'event_outbox'; }
    public function version(): string { return '1.0.0'; }

    /** @return string[] */
    public function dialects(): array { return [ 'mysql', 'postgres' ]; }
    /** @return string[] */
    public function dependencies(): array { return []; }

    public static function contractView(): string { return 'vw_event_outbox'; }

    public function install(Database $db, SqlDialect $d): void
    {
        // 1) Run schema files from ../schema for the dialect (NNN_*.sql order respected)
        SqlDirectoryRunner::run($db, $d, __DIR__ . '/../schema');

        // 2) Contract view = SELECT * FROM <table>
        $table = SqlIdentifier::qi($db, $this->table());
        $view  = SqlIdentifier::qi($db, self::contractView());

        if ($d->isMysql()) {
            $createViewSql = <<<'SQL'
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
SQL;
        } else {
            $createViewSql = <<<'SQL'
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
  (status = 'pending') AS is_pending,
  (status = 'pending' AND (next_attempt_at IS NULL OR next_attempt_at <= now())) AS is_due
FROM event_outbox;
SQL;
        }

        if (\class_exists('\\BlackCat\\Database\\Support\\DdlGuard')) {
            (new \BlackCat\Database\Support\DdlGuard($db, $d))->applyCreateView($createViewSql);
        } else {
            // Prefer CREATE OR REPLACE VIEW (gentle on dependencies)
            $db->exec($createViewSql);
        }

    }

    public function upgrade(Database $db, SqlDialect $d, string $from): void
    {
        // Optional: generator may place module-specific upgrade steps here (e.g., data migrations).
    }

    /** Does not drop the table, only the contract (view). */
    public function uninstall(Database $db, SqlDialect $d): void
    {
        $qiV = SqlIdentifier::qi($db, self::contractView());
        try {
            $db->exec("DROP VIEW IF EXISTS {$qiV}" . ($d->isMysql() ? "" : " CASCADE"));
        } catch (\Throwable) {
            // swallow
        }
    }

    public function status(Database $db, SqlDialect $d): array
    {
        $table = $this->table();
        $view  = self::contractView();

        $hasTable = SchemaIntrospector::hasTable($db, $d, $table);
        $hasView  = SchemaIntrospector::hasView($db, $d, $view);

        // Quick index/FK check â€“ generator injects names (case-sensitive per DB)
        $expectedIdx = [ 'idx_event_outbox_created_at', 'idx_event_outbox_entity_time', 'idx_event_outbox_status_sched' ];
        if ($d->isMysql()) {
            // Drop PG-only index naming patterns (e.g., GIN/GiST)
            $expectedIdx = array_values(array_filter(
                $expectedIdx,
                static fn(string $n): bool => !str_starts_with($n, 'gin_') && !str_starts_with($n, 'gist_')
            ));
        }
        $expectedFk  = [];

        $haveIdx = $hasTable ? SchemaIntrospector::listIndexes($db, $d, $table)     : [];
        $haveFk  = $hasTable ? SchemaIntrospector::listForeignKeys($db, $d, $table) : [];

        $missingIdx = array_values(array_diff($expectedIdx, $haveIdx));
        $missingFk  = array_values(array_diff($expectedFk, $haveFk));

        return [
            'table'       => $hasTable,
            'view'        => $hasView,
            'missing_idx' => $missingIdx,
            'missing_fk'  => $missingFk,
            'version'     => $this->version(),
        ];
    }

    public function info(): array
    {
        return [
            'table'       => $this->table(),
            'view'        => self::contractView(),
            'columns'     => Definitions::columns(),
            'version'     => $this->version(),
            'dialects'    => [ 'mysql', 'postgres' ],
            'indexes'     => [ 'idx_event_outbox_created_at', 'idx_event_outbox_entity_time', 'idx_event_outbox_status_sched' ],
            'foreignKeys' => [],
        ];
    }
}
