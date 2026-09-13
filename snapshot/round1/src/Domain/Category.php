<?php
declare(strict_types=1);

namespace Edpex\Domain;

use Edpex\Domain\Enum\SchemeType;

/** An EdPEx category (1..7) aggregating its items. Immutable. */
final readonly class Category
{
    /** @param Item[] $items */
    public function __construct(
        public string $id,
        public int $n,
        public string $keySlug,
        public string $title,
        public int $points,
        public SchemeType $scheme,
        public array $items,
    ) {
    }

    /** Sum of item points — must equal $points (rubric integrity). */
    public function itemPointsTotal(): int
    {
        return array_sum(array_map(static fn(Item $i): int => $i->points, $this->items));
    }

    public function item(string $code): ?Item
    {
        foreach ($this->items as $it) {
            if ($it->code === $code) {
                return $it;
            }
        }
        return null;
    }
}
