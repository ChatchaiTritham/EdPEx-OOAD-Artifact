<?php
declare(strict_types=1);

namespace Edpex\Domain;

/** An assessor's score for one item: chosen band + percent + the 4 dimension levels. Immutable. */
final readonly class Score
{
    /** @param array<string,int> $dimensions dimensionId => level (0..100) */
    public function __construct(
        public ?string $id,
        public string $assessmentId,
        public string $itemId,
        public ?string $bandId,
        public int $percent,
        public array $dimensions,
        public ?string $strengths = null,
        public ?string $ofi = null,
    ) {
    }

    /** Weighted item score = percent% × item points. */
    public function itemScore(int $itemPoints): float
    {
        return round($itemPoints * $this->percent / 100, 2);
    }

    /** The weakest dimension level — the one that gates the band. */
    public function weakestDimension(): ?int
    {
        return $this->dimensions === [] ? null : min(array_values($this->dimensions));
    }
}
