<?php

declare(strict_types=1);

namespace Edpex\Admission\Repository;

use Edpex\Admission\Entity\VisaRecord;
use Edpex\Security\PdpaCrypto;

final class VisaRecordRepository implements VisaRecordRepositoryInterface
{
    public function __construct(private readonly PdpaCrypto $crypto)
    {
    }

    public function listByPerson(string $personId): array
    {
        $rows = \AppDB::all(
            'SELECT * FROM th_ac_rmutk_ic_visa_records WHERE person_id = ? AND deleted_at IS NULL ORDER BY expiry_date',
            [$personId]
        );
        return array_map($this->hydrate(...), $rows);
    }

    public function listExpiring(int $days): array
    {
        $rows = \AppDB::all(
            'SELECT * FROM th_ac_rmutk_ic_visa_records
              WHERE deleted_at IS NULL AND expiry_date IS NOT NULL
                AND expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL ? DAY)
              ORDER BY expiry_date',
            [$days]
        );
        return array_map($this->hydrate(...), $rows);
    }

    public function findByDocNumber(string $recordType, string $docNumber): ?VisaRecord
    {
        $bidx = $this->crypto->blindIndex($docNumber);
        if ($bidx === '') {
            return null;
        }
        $row = \AppDB::one(
            'SELECT * FROM th_ac_rmutk_ic_visa_records WHERE record_type = ? AND doc_number_bidx = ? AND deleted_at IS NULL',
            [$recordType, $bidx]
        );
        return $row === null ? null : $this->hydrate($row);
    }

    public function save(VisaRecord $record): string
    {
        \AppDB::exec(
            'INSERT INTO th_ac_rmutk_ic_visa_records
                (id, tenant_id, person_id, record_type, doc_number, doc_number_bidx,
                 issue_date, expiry_date, evidence_document_id)
             VALUES (?,?,?,?,?,?,?,?,?)
             ON DUPLICATE KEY UPDATE
                issue_date = VALUES(issue_date), expiry_date = VALUES(expiry_date),
                evidence_document_id = VALUES(evidence_document_id)',
            [
                $record->id, $record->tenantId, $record->personId, $record->recordType,
                $this->crypto->encrypt($record->docNumber), $this->crypto->blindIndex($record->docNumber),
                $record->issueDate, $record->expiryDate, $record->evidenceDocumentId,
            ]
        );
        return $record->id;
    }

    /** @param array<string,mixed> $row */
    private function hydrate(array $row): VisaRecord
    {
        $row['doc_number'] = $this->crypto->decrypt((string) $row['doc_number']);
        return VisaRecord::fromRow($row);
    }
}
