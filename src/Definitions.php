<?php
declare(strict_types=1);

namespace BlackCat\Database\Packages\EventOutbox;

final class Definitions {
    // --- core metadata ---
    public static function table(): string { return 'event_outbox'; }
    public static function contractView(): string { return 'vw_event_outbox'; }
    /** @return string[] */
    public static function columns(): array { return [ 'id', 'event_key', 'entity_table', 'entity_pk', 'event_type', 'payload', 'status', 'attempts', 'next_attempt_at', 'processed_at', 'producer_node', 'created_at' ]; }

    /** @var array<string,array<int,string>> */
    public const STATUS_TRANSITIONS = [];

    /**
     * Table primary key(s). Supports single and composite PK.
     * id may be "id" or "col1, col2".
     * @return string[]
     */
    public static function pkColumns(): array {
        $raw = 'id';
        $parts = array_values(array_filter(array_map(
            static fn($p) => trim($p, " \t\n\r\0\x0B`\""),
            preg_split('/\s*,\s*/', $raw ?? '')
        )));
        if ($parts) {
            return $parts;
        }
        $rawClean = trim((string)$raw, " \t\n\r\0\x0B`\"");
        if ($rawClean === '') {
            throw new \InvalidArgumentException('Definitions::pkColumns(): token id must not be empty.');
        }
        return [$rawClean];
    }

    /**
     * Allowed state transitions (e.g., 'draft' => ['ready'], 'ready' => ['sent','canceled']).
     * @return array<string, string[]>
     */
    public static function statusTransitions(): array {
        return self::STATUS_TRANSITIONS;
    }

    /** Backward compatibility: the first column from the PK. */
    public static function pk(): string { return self::pkColumns()[0]; }

    // --- optional metadata ---
    public static function softDeleteColumn(): ?string {
        $c = ''; return $c !== '' ? $c : null;
    }
    public static function updatedAtColumn(): ?string {
        $c = ''; return $c !== '' ? $c : null;
    }
    public static function versionColumn(): ?string {
        $c = ''; return $c !== '' ? $c : null;
    }
    /** e.g. "created_at DESC, id DESC" */
    public static function defaultOrder(): ?string {
        $c = 'created_at DESC, id DESC'; return $c !== '' ? $c : null;
    }

    /** @return array<int,array<int,string>> list of unique keys */
    public static function uniqueKeys(): array { return [ [ 'event_key' ], [ 'id' ] ]; }

    /** @return string[] JSON columns for casts/operations */
    public static function jsonColumns(): array { return [ 'payload' ]; }

    /** @return string[] List of numeric columns (generator heuristic; no runtime DB queries). */
    public static function intColumns(): array { return [ 'id', 'attempts' ]; }

    /** @return array<string,string> alias => column mapping (for input normalization) */
    public static function paramAliases(): array { return []; }

    /** Repository hint: is the version column actually numeric? (no information_schema needed) */
    public static function versionIsNumeric(): bool
    {
        $v = self::versionColumn();
        return $v !== null && in_array($v, self::intColumns(), true);
    }

    // --- helpers ---
    public static function hasColumn(string $col): bool {
        static $set = null;
        if ($set === null) { $set = array_fill_keys(self::columns(), true); }
        return isset($set[$col]);
    }

    /**
     * identity | uuid | natural | composite
     */
    public static function pkStrategy(): string {
        $c = 'identity';
        return $c !== '' ? $c : 'natural';
    }

    public static function isIdentityPk(): bool {
        return self::pkStrategy() === 'identity';
    }

    /** True when the table is suitable for row-lock tests (no cascading FK, small row width, etc.). */
    public static function isRowLockSafe(): bool {
        return false;
    }

    /** Convenience alias - does the table have a version column for optimistic locking? */
    public static function supportsOptimisticLocking(): bool {
        return self::versionColumn() !== null;
    }

    /** For JSON casts/operations - fast test without building a set. */
    public static function hasJsonColumn(string $col): bool {
        static $set = null;
        if ($set === null) { $set = array_fill_keys(self::jsonColumns(), true); }
        return isset($set[$col]);
    }

    public static function isSoftDeleteEnabled(): bool { return self::softDeleteColumn() !== null; }

    /** @return string[] Columns containing PII for log/telemetry masking (module-specific). */
    public static function piiColumns(): array { return []; }

    // --- derived "HAS_*" flags as methods (instead of constants calling functions) ---
    public static function hasTenant(): bool {
        return in_array('tenant_id', self::columns(), true);
    }
    public static function hasDeletedAt(): bool {
        return self::softDeleteColumn() !== null;
    }
    public static function hasUuid(): bool {
        $cols = self::columns();
        return in_array('uuid', $cols, true) || in_array('uuid_bin', $cols, true);
    }
}
