<?php

declare(strict_types=1);

namespace Edpex\Admission\Entity;

/** visa_records, hydrated with doc_number already decrypted by the Repository. */
final class VisaRecord
{
    public function __construct(
        public readonly string $id,
        public readonly string $tenantId,
        public readonly string $personId,
        public readonly string $recordType,
        public readonly string $docNumber,
        public readonly ?string $issueDate,
        public readonly ?string $expiryDate,
        public readonly ?string $evidenceDocumentId,
        public readonly ?string $deletedAt,
        public readonly string $createdAt,
    ) {
    }

    /** @param array<string,mixed> $row raw visa_records row with doc_number already decrypted */
    public static function fromRow(array $row): self
    {
        return new self(
            id: (string) $row['id'],
            tenantId: (string) $row['tenant_id'],
            personId: (string) $row['person_id'],
            recordType: (string) $row['record_type'],
            docNumber: (string) $row['doc_number'],
            issueDate: $row['issue_date'] !== null ? (string) $row['issue_date'] : null,
            expiryDate: $row['expiry_date'] !== null ? (string) $row['expiry_date'] : null,
            evidenceDocumentId: $row['evidence_document_id'] !== null ? (string) $row['evidence_document_id'] : null,
            deletedAt: $row['deleted_at'] !== null ? (string) $row['deleted_at'] : null,
            createdAt: (string) $row['created_at'],
        );
    }
}
