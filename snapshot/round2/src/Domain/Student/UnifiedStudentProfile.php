<?php
declare(strict_types=1);

namespace Edpex\Domain\Student;

/**
 * Aggregate Root representing the complete, unified student persona across all degree tiers.
 */
final class UnifiedStudentProfile
{
    private string $activeStudentCode;

    /**
     * @param list<AcademicDegreeRecord> $degrees
     */
    public function __construct(
        public readonly StudentIdentity $identity,
        private array $degrees,
        string $initialActiveCode
    ) {
        $this->activeStudentCode = $initialActiveCode;
        if (!$this->hasDegree($initialActiveCode) && $this->degrees !== []) {
            $this->activeStudentCode = $this->degrees[0]->studentCode;
        }
    }

    public function getActiveStudentCode(): string
    {
        return $this->activeStudentCode;
    }

    public function getActiveDegree(): ?AcademicDegreeRecord
    {
        foreach ($this->degrees as $deg) {
            if ($deg->studentCode === $this->activeStudentCode) {
                return $deg;
            }
        }
        return $this->degrees[0] ?? null;
    }

    /**
     * @return list<AcademicDegreeRecord>
     */
    public function getDegrees(): array
    {
        return $this->degrees;
    }

    public function hasMultipleDegrees(): bool
    {
        return count($this->degrees) > 1;
    }

    public function hasDegree(string $studentCode): bool
    {
        foreach ($this->degrees as $deg) {
            if ($deg->studentCode === $studentCode) {
                return true;
            }
        }
        return false;
    }

    public function switchDegree(string $targetStudentCode): bool
    {
        if ($this->hasDegree($targetStudentCode)) {
            $this->activeStudentCode = $targetStudentCode;
            return true;
        }
        return false;
    }

    public function getTimeline(): AcademicJourneyTimeline
    {
        return new AcademicJourneyTimeline($this->degrees, $this->activeStudentCode);
    }
}
