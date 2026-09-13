<?php
declare(strict_types=1);

namespace Edpex\Repository;

use Edpex\Domain\Score;
use Edpex\Support\Db;

/** Persists Score aggregates (scores row + normalized score_dimensions) for one assessment. */
final class ScoreRepository
{
    public function __construct(private readonly string $assessmentId)
    {
    }

    /** Cast a mixed DB value to string (null / non-scalar → ''). */
    private static function str(mixed $v): string
    {
        return is_scalar($v) ? (string) $v : '';
    }

    /** Cast a mixed DB value to int (null / non-scalar → 0). */
    private static function int_(mixed $v): int
    {
        return is_scalar($v) ? (int) $v : 0;
    }

    /** Load a Score for an item (by ref_items.id), with its dimension levels. */
    public function findByItem(string $itemId): ?Score
    {
        $row = Db::one(
            "SELECT id, item_id, band_id, score_pct, strengths, ofi
               FROM {scores} WHERE assessment_id = ? AND item_id = ? LIMIT 1",
            [$this->assessmentId, $itemId]
        );
        if ($row === null) {
            return null;
        }
        $dims = [];
        foreach (Db::all("SELECT dimension_id, level FROM score_dimensions WHERE score_id = ?", [self::str($row['id'])]) as $d) {
            $dims[self::str($d['dimension_id'])] = self::int_($d['level']);
        }
        return new Score(
            id: self::str($row['id']),
            assessmentId: $this->assessmentId,
            itemId: self::str($row['item_id']),
            bandId: $row['band_id'] !== null ? self::str($row['band_id']) : null,
            percent: self::int_($row['score_pct']),
            dimensions: $dims,
            strengths: $row['strengths'] !== null ? self::str($row['strengths']) : null,
            ofi: $row['ofi'] !== null ? self::str($row['ofi']) : null,
        );
    }

    /**
     * Upsert a Score + replace its dimensions atomically. Returns the score id.
     * Resolves the legacy item_code + band range_label from the reference tables so the legacy
     * unique key (assessment_id, item_code) and the `band` text column stay consistent.
     */
    public function save(Score $score, ?string $userId = null): string
    {
        return Db::transaction(function () use ($score, $userId): string {
            $itemCode  = self::str(Db::scalar("SELECT code FROM ref_items WHERE id = ?", [$score->itemId]));
            $bandLabel = $score->bandId !== null
                ? Db::scalar("SELECT range_label FROM ref_scoring_bands WHERE id = ?", [$score->bandId])
                : null;

            $existingId = Db::scalar(
                "SELECT id FROM {scores} WHERE assessment_id = ? AND item_code = ? LIMIT 1",
                [$score->assessmentId, $itemCode]
            );
            $id = $existingId !== false && $existingId !== null ? self::str($existingId) : \appUuid();

            if ($existingId !== false && $existingId !== null) {
                Db::exec(
                    "UPDATE {scores} SET item_id = ?, band = ?, band_id = ?, score_pct = ?, strengths = ?, ofi = ?, updated_by = ?, updated_at = NOW()
                       WHERE id = ?",
                    [$score->itemId, $bandLabel, $score->bandId, $score->percent, $score->strengths, $score->ofi, $userId, $id]
                );
            } else {
                Db::exec(
                    "INSERT INTO {scores} (id, assessment_id, item_code, item_id, band, band_id, score_pct, strengths, ofi, updated_by, updated_at)
                     VALUES (?,?,?,?,?,?,?,?,?,?,NOW())",
                    [$id, $score->assessmentId, $itemCode, $score->itemId, $bandLabel, $score->bandId, $score->percent, $score->strengths, $score->ofi, $userId]
                );
            }

            Db::exec("DELETE FROM score_dimensions WHERE score_id = ?", [$id]);
            foreach ($score->dimensions as $dimensionId => $level) {
                Db::exec(
                    "INSERT INTO score_dimensions (id, score_id, dimension_id, level) VALUES (?,?,?,?)",
                    [\appUuid(), $id, $dimensionId, $level]
                );
            }
            return $id;
        });
    }

    /** @return array<string,float> itemCode => itemScore, for overall roll-up. */
    public function itemScores(): array
    {
        $out = [];
        foreach (Db::all(
            "SELECT s.score_pct, i.code, i.points
               FROM {scores} s JOIN ref_items i ON i.id = s.item_id
              WHERE s.assessment_id = ?",
            [$this->assessmentId]
        ) as $r) {
            $out[self::str($r['code'])] = round(self::int_($r['points']) * self::int_($r['score_pct']) / 100, 2);
        }
        return $out;
    }
}
