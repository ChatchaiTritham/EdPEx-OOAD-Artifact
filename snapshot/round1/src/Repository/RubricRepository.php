<?php
declare(strict_types=1);

namespace Edpex\Repository;

use Edpex\Domain\Band;
use Edpex\Domain\Category;
use Edpex\Domain\Dimension;
use Edpex\Domain\Enum\SchemeType;
use Edpex\Domain\Framework;
use Edpex\Domain\Item;
use Edpex\Domain\ScoringScheme;
use Edpex\Support\Db;

/** Loads the normalized rubric (ref_* tables) into the Framework aggregate. */
final class RubricRepository
{
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

    /** Build the full Framework graph from the normalized reference tables. */
    public function load(string $code = 'EdPEx', string $edition = '2567-2570'): ?Framework
    {
        $fw = Db::one(
            "SELECT id, code, edition, max_points FROM ref_frameworks WHERE code = ? AND edition = ? LIMIT 1",
            [$code, $edition]
        );
        if ($fw === null) {
            return null;
        }
        $fwId = self::str($fw['id']);

        return new Framework(
            id:         $fwId,
            code:       self::str($fw['code']),
            edition:    self::str($fw['edition']),
            maxPoints:  self::int_($fw['max_points']),
            categories: $this->loadCategories($fwId),
            schemes:    $this->loadSchemes($fwId),
        );
    }

    /** @return array<string,ScoringScheme> keyed by scheme code */
    private function loadSchemes(string $fwId): array
    {
        $out = [];
        foreach (Db::all("SELECT id, code, name FROM ref_scoring_schemes WHERE framework_id = ?", [$fwId]) as $s) {
            $sid  = self::str($s['id']);
            $dims = array_map(
                static fn(array $r): Dimension => new Dimension(self::str($r['id']), self::int_($r['ordinal']), self::str($r['code']), self::str($r['name_th'])),
                Db::all("SELECT id, ordinal, code, name_th FROM ref_scoring_dimensions WHERE scheme_id = ? ORDER BY ordinal", [$sid])
            );
            $bands = [];
            foreach (Db::all("SELECT id, ordinal, range_label, low_pct, high_pct, label, descr FROM ref_scoring_bands WHERE scheme_id = ? ORDER BY ordinal", [$sid]) as $b) {
                $choices = array_map(
                    static fn(array $c): int => self::int_($c['percent']),
                    Db::all("SELECT percent FROM ref_band_choices WHERE band_id = ? ORDER BY percent", [self::str($b['id'])])
                );
                $bands[] = new Band(
                    self::str($b['id']), self::int_($b['ordinal']), self::str($b['range_label']),
                    self::int_($b['low_pct']), self::int_($b['high_pct']), self::str($b['label']), self::str($b['descr']), $choices
                );
            }
            $out[self::str($s['code'])] = new ScoringScheme($sid, SchemeType::from(self::str($s['code'])), self::str($s['name']), $dims, $bands);
        }
        return $out;
    }

    /** @return Category[] */
    private function loadCategories(string $fwId): array
    {
        $cats = [];
        foreach (Db::all("SELECT id, n, key_slug, title, points, scoring_code FROM ref_categories WHERE framework_id = ? ORDER BY n", [$fwId]) as $c) {
            $items = array_map(
                static fn(array $r): Item => new Item(self::str($r['id']), self::str($r['code']), self::str($r['title']), self::int_($r['points'])),
                Db::all("SELECT id, code, title, points FROM ref_items WHERE category_id = ? ORDER BY sort, code", [self::str($c['id'])])
            );
            $cats[] = new Category(
                self::str($c['id']), self::int_($c['n']), self::str($c['key_slug']), self::str($c['title']),
                self::int_($c['points']), SchemeType::from(self::str($c['scoring_code'])), $items
            );
        }
        return $cats;
    }
}
