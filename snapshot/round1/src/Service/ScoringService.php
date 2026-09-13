<?php
declare(strict_types=1);

namespace Edpex\Service;

use Edpex\Domain\Band;
use Edpex\Domain\ScoringScheme;
use DomainException;

/**
 * The EdPEx holistic + weakest-gate scoring engine (criteria p.79–81).
 *
 *  - holistic: the assessor picks the Band that best reflects the whole, then a discrete percent
 *    from that band's `choices` (NOT a continuous range).
 *  - weakest-gate: the chosen band may not exceed the band supported by the weakest dimension —
 *    "the weakest dimension gates the band".
 *  - item_score = percent% × item.points ; category = Σ item ; overall = Σ category (≤ 1000).
 *
 * Pure domain logic: no I/O, fully unit-testable.
 */
final class ScoringService
{
    /** A percent must be one of the band's discrete choices. @throws DomainException */
    public function assertChoice(Band $band, int $percent): void
    {
        if (!$band->allowsChoice($percent)) {
            throw new DomainException(
                "percent {$percent} is not a valid choice in band {$band->rangeLabel} (" . implode('/', $band->choices) . ')'
            );
        }
    }

    /**
     * The effective ceiling band: the band into which the WEAKEST dimension level falls.
     * @param array<string,int> $dimensions dimensionId => level (0..100)
     */
    public function gateBand(ScoringScheme $scheme, array $dimensions): ?Band
    {
        if ($dimensions === []) {
            return null;
        }
        return $scheme->bandForPercent(min(array_values($dimensions)));
    }

    /**
     * True if the chosen band is within the gate (≤ the weakest-supported band).
     * @param array<string,int> $dimensions
     */
    public function passesGate(ScoringScheme $scheme, Band $chosen, array $dimensions): bool
    {
        $gate = $this->gateBand($scheme, $dimensions);
        return $gate === null || $chosen->ordinal <= $gate->ordinal;
    }

    /**
     * Validate a complete scoring decision and return the normalized result.
     * @param array<string,int> $dimensions
     * @return array{band_id:string,percent:int,item_points:int,item_score:float}
     * @throws DomainException on an illegal choice or a gate violation
     */
    public function evaluate(ScoringScheme $scheme, Band $chosen, int $percent, array $dimensions, int $itemPoints): array
    {
        $this->assertChoice($chosen, $percent);
        if (!$this->passesGate($scheme, $chosen, $dimensions)) {
            $gate = $this->gateBand($scheme, $dimensions);
            throw new DomainException(
                "gate violation: the weakest dimension caps the band at '{$gate?->label}' ({$gate?->rangeLabel}); "
                . "chosen band '{$chosen->label}' ({$chosen->rangeLabel}) is too high"
            );
        }
        return [
            'band_id'     => $chosen->id,
            'percent'     => $percent,
            'item_points' => $itemPoints,
            'item_score'  => $this->itemScore($percent, $itemPoints),
        ];
    }

    public function itemScore(int $percent, int $points): float
    {
        return round($points * $percent / 100, 2);
    }

    /**
     * Overall weighted EdPEx score (≤ 1000) from a map of item scores.
     * @param array<string,float> $itemScores itemCode => itemScore
     */
    public function overall(array $itemScores): float
    {
        return round(array_sum($itemScores), 1);
    }
}
