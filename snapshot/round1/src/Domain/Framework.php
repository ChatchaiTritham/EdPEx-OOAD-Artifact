<?php
declare(strict_types=1);

namespace Edpex\Domain;

/** The EdPEx framework aggregate root: categories + scoring schemes. Immutable. */
final readonly class Framework
{
    /**
     * @param Category[]               $categories
     * @param array<string,ScoringScheme> $schemes keyed by scheme code (ADLI|LeTCI)
     */
    public function __construct(
        public string $id,
        public string $code,
        public string $edition,
        public int $maxPoints,
        public array $categories,
        public array $schemes,
    ) {
    }

    public function category(int $n): ?Category
    {
        foreach ($this->categories as $c) {
            if ($c->n === $n) {
                return $c;
            }
        }
        return null;
    }

    public function scheme(string $code): ?ScoringScheme
    {
        return $this->schemes[$code] ?? null;
    }

    /** Total points across categories — must equal maxPoints (1000). */
    public function totalPoints(): int
    {
        return array_sum(array_map(static fn(Category $c): int => $c->points, $this->categories));
    }

    /** Resolve an Item by its code across all categories. */
    public function item(string $code): ?Item
    {
        foreach ($this->categories as $c) {
            if (($it = $c->item($code)) !== null) {
                return $it;
            }
        }
        return null;
    }
}
