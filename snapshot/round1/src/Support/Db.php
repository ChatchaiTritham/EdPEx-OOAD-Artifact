<?php
declare(strict_types=1);

namespace Edpex\Support;

/**
 * Thin namespaced facade over the global \AppDB (config/db.php) so the OO layer keeps a single
 * connection + the SaaS {token} substitution, without re-implementing the PDO wrapper.
 */
final class Db
{
    /**
     * @param array<int|string,mixed> $params
     * @return array<int,array<string,mixed>>
     */
    public static function all(string $sql, array $params = []): array
    {
        /** @var array<int,array<string,mixed>> $rows */
        $rows = \AppDB::all($sql, $params);
        return $rows;
    }

    /**
     * @param array<int|string,mixed> $params
     * @return array<string,mixed>|null
     */
    public static function one(string $sql, array $params = []): ?array
    {
        /** @var array<string,mixed>|null $row */
        $row = \AppDB::one($sql, $params);
        return $row;
    }

    /** @param array<int|string,mixed> $params */
    public static function scalar(string $sql, array $params = []): mixed
    {
        return \AppDB::scalar($sql, $params);
    }

    /** @param array<int|string,mixed> $params */
    public static function exec(string $sql, array $params = []): int
    {
        return \AppDB::exec($sql, $params);
    }

    /**
     * @template T
     * @param callable():T $fn
     * @return T
     */
    public static function transaction(callable $fn): mixed
    {
        return \AppDB::transaction($fn);
    }
}
