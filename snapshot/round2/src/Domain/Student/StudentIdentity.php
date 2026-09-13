<?php
declare(strict_types=1);

namespace Edpex\Domain\Student;

/**
 * Value Object encapsulating a student's core identity attributes across records.
 */
final class StudentIdentity
{
    public function __construct(
        public readonly string $personId,
        public readonly string $studentCode,
        public readonly string $nameEn,
        public readonly string $nameTh,
        public readonly ?string $passportNo = null,
        public readonly ?string $citizenId = null,
        public readonly ?string $dateOfBirth = null,
        public readonly ?string $email = null
    ) {
    }

    /**
     * Determines if this identity matches another record (same physical person).
     */
    public function matches(self $other): bool
    {
        // 1. Direct passport match
        if (
            $this->passportNo !== null && $this->passportNo !== '' &&
            $other->passportNo !== null && $other->passportNo !== '' &&
            strcasecmp($this->passportNo, $other->passportNo) === 0
        ) {
            return true;
        }

        // 2. Direct citizen ID match
        if (
            $this->citizenId !== null && $this->citizenId !== '' &&
            $other->citizenId !== null && $other->citizenId !== '' &&
            strcasecmp($this->citizenId, $other->citizenId) === 0
        ) {
            return true;
        }

        // 3. Name (EN) + DOB match
        if (
            $this->dateOfBirth !== null && $this->dateOfBirth !== '' &&
            $this->dateOfBirth === $other->dateOfBirth &&
            $this->normalizeName($this->nameEn) === $this->normalizeName($other->nameEn) &&
            $this->normalizeName($this->nameEn) !== ''
        ) {
            return true;
        }

        // 4. Exact Full Thai Name match
        if (
            $this->nameTh !== '' && $other->nameTh !== '' &&
            $this->nameTh === $other->nameTh &&
            ($this->dateOfBirth === $other->dateOfBirth || $this->dateOfBirth === null || $other->dateOfBirth === null)
        ) {
            return true;
        }

        return false;
    }

    private function normalizeName(string $name): string
    {
        $parts = preg_split('/\s+/', strtoupper(trim($name)));
        if ($parts === false || $parts === []) {
            return '';
        }
        sort($parts);
        return implode(' ', $parts);
    }
}
