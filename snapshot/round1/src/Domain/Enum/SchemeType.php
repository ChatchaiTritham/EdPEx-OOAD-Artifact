<?php
declare(strict_types=1);

namespace Edpex\Domain\Enum;

/** EdPEx scoring scheme: ADLI for process categories 1–6, LeTCI for results category 7. */
enum SchemeType: string
{
    case ADLI  = 'ADLI';
    case LeTCI = 'LeTCI';

    /** LeTCI applies to results (category 7); ADLI to process (1–6). */
    public function appliesToResults(): bool
    {
        return $this === self::LeTCI;
    }

    public static function fromCategoryType(string $catType): self
    {
        return $catType === 'results' ? self::LeTCI : self::ADLI;
    }
}
