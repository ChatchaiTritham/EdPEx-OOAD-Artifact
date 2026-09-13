<?php
declare(strict_types=1);

namespace Edpex\Domain;

use Edpex\Domain\Enum\SchemeType;

/** A scoring scheme (ADLI|LeTCI) with its 4 dimensions and ascending bands. Immutable. */
final readonly class ScoringScheme
{
    /**
     * @param Dimension[] $dimensions ordered by ordinal
     * @param Band[]      $bands      ordered ascending by ordinal
     */
    public function __construct(
        public string $id,
        public SchemeType $type,
        public string $name,
        public array $dimensions,
        public array $bands,
    ) {
    }

    public function bandByOrdinal(int $ordinal): ?Band
    {
        foreach ($this->bands as $b) {
            if ($b->ordinal === $ordinal) {
                return $b;
            }
        }
        return null;
    }

    public function bandById(string $id): ?Band
    {
        foreach ($this->bands as $b) {
            if ($b->id === $id) {
                return $b;
            }
        }
        return null;
    }

    /** The highest band whose lower bound <= $percent (the band a percent falls into). */
    public function bandForPercent(int $percent): ?Band
    {
        $found = null;
        foreach ($this->bands as $b) {           // ascending
            if ($percent >= $b->lowPct) {
                $found = $b;
            }
        }
        return $found;
    }
}
