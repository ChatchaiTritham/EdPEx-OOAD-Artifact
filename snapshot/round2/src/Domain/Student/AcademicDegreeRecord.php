<?php
declare(strict_types=1);

namespace Edpex\Domain\Student;

/**
 * Entity representing an academic degree enrollment tier.
 */
final class AcademicDegreeRecord
{
    public function __construct(
        public readonly string $personId,
        public readonly string $studentCode,
        public readonly string $degreeLevel,
        public readonly string $programNameEn,
        public readonly string $programNameTh,
        public readonly int $admitYear,
        public readonly string $statusName,
        public readonly string $statusCode,
        public readonly float $gpax,
        public readonly int $creditsEarned,
        public readonly ?string $advisorName = null,
        public readonly ?string $campusName = null,
        public readonly ?string $facultyName = null
    ) {
    }

    /**
     * Infer degree level category: 'bachelor', 'master', 'doctoral', or 'other'.
     */
    public function getDegreeTier(): string
    {
        $codeDigit = substr($this->studentCode, 2, 1);
        if ($codeDigit === '5' || str_contains($this->degreeLevel, 'ตรี') || stripos($this->degreeLevel, 'bachelor') !== false) {
            return 'bachelor';
        }
        if ($codeDigit === '8' || str_contains($this->degreeLevel, 'โท') || stripos($this->degreeLevel, 'master') !== false) {
            return 'master';
        }
        if ($codeDigit === '9' || str_contains($this->degreeLevel, 'เอก') || stripos($this->degreeLevel, 'doctoral') !== false || stripos($this->degreeLevel, 'phd') !== false) {
            return 'doctoral';
        }
        return 'other';
    }

    public function getDegreeTierLabelEn(): string
    {
        return match ($this->getDegreeTier()) {
            'bachelor' => "Bachelor's Degree",
            'master' => "Master's Degree",
            'doctoral' => "Doctoral Degree (Ph.D.)",
            default => $this->degreeLevel ?: 'Degree Program',
        };
    }

    public function getDegreeTierLabelTh(): string
    {
        return match ($this->getDegreeTier()) {
            'bachelor' => 'ระดับปริญญาตรี',
            'master' => 'ระดับปริญญาโท',
            'doctoral' => 'ระดับปริญญาเอก',
            default => $this->degreeLevel ?: 'หลักสูตรการศึกษา',
        };
    }

    public function isGraduated(): bool
    {
        return str_contains($this->statusName, 'สำเร็จ') || stripos($this->statusName, 'graduate') !== false || $this->statusCode === 'GRAD';
    }

    public function isActive(): bool
    {
        return str_contains($this->statusName, 'ปกติ') || stripos($this->statusName, 'active') !== false || $this->statusCode === 'ACT';
    }
}
