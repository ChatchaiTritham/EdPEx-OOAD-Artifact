<?php
declare(strict_types=1);

namespace Edpex\Domain\Student;

/**
 * Domain service & model representing the continuous academic timeline across all degrees.
 */
final class AcademicJourneyTimeline
{
    /** @var array<int, array{
     *     tier: string,
     *     title_en: string,
     *     title_th: string,
     *     program_en: string,
     *     program_th: string,
     *     student_code: string,
     *     admit_year_be: int,
     *     admit_year_ad: int,
     *     status: string,
     *     gpax: float,
     *     credits: int,
     *     is_current: bool,
     *     is_graduated: bool
     * }>
     */
    private array $stages = [];

    /**
     * @param list<AcademicDegreeRecord> $degrees
     */
    public function __construct(array $degrees, string $activeStudentCode)
    {
        // Sort chronologically by admit year + degree tier
        $sorted = $degrees;
        usort($sorted, function (AcademicDegreeRecord $a, AcademicDegreeRecord $b): int {
            if ($a->admitYear !== $b->admitYear) {
                return $a->admitYear <=> $b->admitYear;
            }
            $tierOrder = ['bachelor' => 1, 'master' => 2, 'doctoral' => 3, 'other' => 4];
            return ($tierOrder[$a->getDegreeTier()] ?? 99) <=> ($tierOrder[$b->getDegreeTier()] ?? 99);
        });

        foreach ($sorted as $deg) {
            $this->stages[] = [
                'tier' => $deg->getDegreeTier(),
                'title_en' => $deg->getDegreeTierLabelEn(),
                'title_th' => $deg->getDegreeTierLabelTh(),
                'program_en' => $deg->programNameEn ?: $deg->programNameTh,
                'program_th' => $deg->programNameTh ?: $deg->programNameEn,
                'student_code' => $deg->studentCode,
                'admit_year_be' => $deg->admitYear,
                'admit_year_ad' => $deg->admitYear > 2400 ? $deg->admitYear - 543 : $deg->admitYear,
                'status' => $deg->statusName,
                'gpax' => $deg->gpax,
                'credits' => $deg->creditsEarned,
                'is_current' => ($deg->studentCode === $activeStudentCode),
                'is_graduated' => $deg->isGraduated(),
            ];
        }
    }

    /**
     * @return array<int, array{
     *     tier: string,
     *     title_en: string,
     *     title_th: string,
     *     program_en: string,
     *     program_th: string,
     *     student_code: string,
     *     admit_year_be: int,
     *     admit_year_ad: int,
     *     status: string,
     *     gpax: float,
     *     credits: int,
     *     is_current: bool,
     *     is_graduated: bool
     * }>
     */
    public function getStages(): array
    {
        return $this->stages;
    }

    public function count(): int
    {
        return count($this->stages);
    }
}
