<?php
declare(strict_types=1);

namespace Edpex\Domain;

/** One scoring dimension (A/D/L/I or Le/T/C/I). Immutable value object. */
final readonly class Dimension
{
    public function __construct(
        public string $id,
        public int $ordinal,    // 1..4
        public string $code,    // A, D, L, I | Le, T, C, I
        public string $nameTh,
    ) {
    }
}
