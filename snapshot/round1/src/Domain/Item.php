<?php
declare(strict_types=1);

namespace Edpex\Domain;

/** An EdPEx item (1.1 .. 7.5) with its point weight. Immutable. */
final readonly class Item
{
    public function __construct(
        public string $id,
        public string $code,     // '1.1'
        public string $title,
        public int $points,
    ) {
    }
}
