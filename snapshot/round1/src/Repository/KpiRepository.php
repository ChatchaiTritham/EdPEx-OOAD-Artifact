<?php
declare(strict_types=1);

namespace Edpex\Repository;

use Edpex\Support\Db;

/** Reads/writes normalized KPIs (kpi_definitions + per-year kpi_values) for a tenant. */
final class KpiRepository
{
    public function __construct(private readonly string $tenantId)
    {
    }

    /**
     * KPI definitions joined to a given academic year's value.
     * @return array<int,array<string,mixed>>
     */
    public function forYear(int $year): array
    {
        return Db::all(
            "SELECT d.id AS definition_id, d.code, d.name, d.unit, c.n AS category_n,
                    v.target_value, v.actual_value, v.academic_year
               FROM kpi_definitions d
               LEFT JOIN ref_categories c ON c.id = d.category_id
               LEFT JOIN kpi_values v ON v.kpi_definition_id = d.id AND v.academic_year = ?
              WHERE d.tenant_id = ?
              ORDER BY d.code",
            [$year, $this->tenantId]
        );
    }

    /** Upsert a definition (by tenant+code) and return its id. */
    public function upsertDefinition(string $code, string $name, ?string $unit, ?string $categoryId, ?string $itemId, ?string $frameworkId): string
    {
        $id = Db::scalar("SELECT id FROM kpi_definitions WHERE tenant_id = ? AND code = ?", [$this->tenantId, $code]);
        if ($id !== false && $id !== null) {
            Db::exec(
                "UPDATE kpi_definitions SET name = ?, unit = ?, category_id = ?, item_id = ?, framework_id = ? WHERE id = ?",
                [$name, $unit, $categoryId, $itemId, $frameworkId, $id]
            );
            return is_scalar($id) ? (string) $id : '';
        }
        $id = \appUuid();
        Db::exec(
            "INSERT INTO kpi_definitions (id, tenant_id, framework_id, code, name, category_id, item_id, unit)
             VALUES (?,?,?,?,?,?,?,?)",
            [$id, $this->tenantId, $frameworkId, $code, $name, $categoryId, $itemId, $unit]
        );
        return $id;
    }

    /** Upsert a yearly value (by definition+year) and return its id. */
    public function upsertValue(string $definitionId, int $year, ?float $target, ?float $actual): string
    {
        $id = Db::scalar(
            "SELECT id FROM kpi_values WHERE kpi_definition_id = ? AND academic_year = ?",
            [$definitionId, $year]
        );
        if ($id !== false && $id !== null) {
            Db::exec(
                "UPDATE kpi_values SET target_value = ?, actual_value = ?, updated_at = NOW() WHERE id = ?",
                [$target, $actual, $id]
            );
            return is_scalar($id) ? (string) $id : '';
        }
        $id = \appUuid();
        Db::exec(
            "INSERT INTO kpi_values (id, tenant_id, kpi_definition_id, academic_year, target_value, actual_value)
             VALUES (?,?,?,?,?,?,?)",
            [$id, $this->tenantId, $definitionId, $year, $target, $actual]
        );
        return $id;
    }
}
