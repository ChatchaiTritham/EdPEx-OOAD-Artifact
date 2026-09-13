<?php

declare(strict_types=1);

namespace Edpex\Admission\Repository;

use Edpex\Admission\Entity\VisaRecord;

interface VisaRecordRepositoryInterface
{
    /** @return list<VisaRecord> */
    public function listByPerson(string $personId): array;

    /** @return list<VisaRecord> expiring within $days days, not already deleted */
    public function listExpiring(int $days): array;

    public function findByDocNumber(string $recordType, string $docNumber): ?VisaRecord;

    public function save(VisaRecord $record): string;
}
