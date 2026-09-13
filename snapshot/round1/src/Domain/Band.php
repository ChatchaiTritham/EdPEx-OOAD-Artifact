<?php
declare(strict_types=1);

namespace Edpex\Domain;

/** A scoring band (e.g. '50-65%') with its discrete percent choices. Immutable. */
final readonly class Band
{
    /** @param int[] $choices discrete legal percents within the band */
    public function __construct(
        public string $id,
        public int $ordinal,        // 1..6, ascending
        public string $rangeLabel,  // '50-65%'
        public int $lowPct,
        public int $highPct,
        public string $label,
        public string $descr,
        public array $choices,
    ) {
    }

    /** A percent is legal only if it is one of the band's discrete choices (criteria p.79). */
    public function allowsChoice(int $percent): bool
    {
        return in_array($percent, $this->choices, true);
    }

    public function contains(int $percent): bool
    {
        return $percent >= $this->lowPct && $percent <= $this->highPct;
    }
}
