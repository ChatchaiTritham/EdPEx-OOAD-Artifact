<?php
declare(strict_types=1);

namespace Edpex\Service;

use Edpex\Domain\Category;
use Edpex\Domain\Framework;
use Edpex\Domain\Score;
use Edpex\Repository\RubricRepository;
use Edpex\Repository\ScoreRepository;
use DomainException;
use RuntimeException;

/** Use-case orchestration: score an item end-to-end and roll up the overall EdPEx score. */
final class AssessmentService
{
    public function __construct(
        private readonly RubricRepository $rubric,
        private readonly ScoringService $scoring,
    ) {
    }

    /**
     * Score one item (UC-01): resolve its scheme, enforce the weakest-gate rule, persist the
     * normalized Score + dimensions, and return the evaluation result.
     *
     * @param array<int,int> $dimLevels dimension ORDINAL (1..4) => level (0..100)
     * @return array{band_id:string,percent:int,item_points:int,item_score:float,score_id:string}
     */
    public function scoreItem(
        string $assessmentId,
        string $itemCode,
        int $bandOrdinal,
        int $percent,
        array $dimLevels,
        ?string $userId = null,
        ?string $strengths = null,
        ?string $ofi = null,
    ): array {
        $fw  = $this->rubric->load() ?? throw new RuntimeException('rubric not seeded (run tools/seed_rubric.php)');
        $cat = $this->categoryOfItem($fw, $itemCode) ?? throw new DomainException("unknown item {$itemCode}");
        $item = $cat->item($itemCode) ?? throw new DomainException("item {$itemCode} not found in category");
        $scheme = $fw->scheme($cat->scheme->value) ?? throw new RuntimeException("scheme {$cat->scheme->value} not loaded");
        $band = $scheme->bandByOrdinal($bandOrdinal) ?? throw new DomainException("invalid band ordinal {$bandOrdinal}");

        // map dimension ordinal → id for both the gate and persistence
        $dimById = [];
        foreach ($scheme->dimensions as $d) {
            if (array_key_exists($d->ordinal, $dimLevels)) {
                $dimById[$d->id] = (int) $dimLevels[$d->ordinal];
            }
        }

        $result = $this->scoring->evaluate($scheme, $band, $percent, $dimById, $item->points);

        $repo = new ScoreRepository($assessmentId);
        $scoreId = $repo->save(new Score(
            id: null,
            assessmentId: $assessmentId,
            itemId: $item->id,
            bandId: $band->id,
            percent: $percent,
            dimensions: $dimById,
            strengths: $strengths,
            ofi: $ofi,
        ), $userId);

        $result['score_id'] = $scoreId;
        return $result;
    }

    /** Overall EdPEx score (≤ 1000) for an assessment from its persisted item scores. */
    public function overall(string $assessmentId): float
    {
        return $this->scoring->overall((new ScoreRepository($assessmentId))->itemScores());
    }

    private function categoryOfItem(Framework $fw, string $itemCode): ?Category
    {
        foreach ($fw->categories as $c) {
            if ($c->item($itemCode) !== null) {
                return $c;
            }
        }
        return null;
    }
}
