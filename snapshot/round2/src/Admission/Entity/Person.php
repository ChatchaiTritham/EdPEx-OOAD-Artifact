<?php

declare(strict_types=1);

namespace Edpex\Admission\Entity;

/**
 * students, hydrated with PII columns already DECRYPTED by the Repository — this entity always
 * holds the full plaintext. Whether a caller is allowed to SEE dateOfBirth/passportNo is decided
 * later, by PersonAccessPolicy — never here (see OOA/OOD review: mixing that decision into data
 * access was the Single-Responsibility violation this split fixes).
 */
final class Person
{
    public function __construct(
        public readonly string $id,
        public readonly string $tenantId,
        public readonly ?string $studentCode,
        public readonly ?string $title,
        public readonly ?string $nameTh,
        public readonly ?string $nameEn,
        public readonly ?string $nationalityCode,
        public readonly ?string $dateOfBirth,
        public readonly ?string $passportNo,
        public readonly ?string $passportIssueDate,
        public readonly ?string $passportExpiryDate,
        public readonly ?string $citizenIdNo,
        public readonly ?string $thResidenceEvidenceId,
        public readonly ?string $deletedAt,
        public readonly ?string $anonymizedAt,
        public readonly string $createdAt,
        public readonly string $updatedAt,
    ) {
    }

    /** @param array<string,mixed> $row raw students row with PII columns already decrypted */
    public static function fromRow(array $row): self
    {
        return new self(
            id: (string) $row['id'],
            tenantId: (string) $row['tenant_id'],
            studentCode: $row['student_code'] !== null ? (string) $row['student_code'] : null,
            title: $row['title'] !== null ? (string) $row['title'] : null,
            nameTh: $row['name_th'] !== null ? (string) $row['name_th'] : null,
            nameEn: $row['name_en'] !== null ? (string) $row['name_en'] : null,
            nationalityCode: $row['nationality_code'] !== null ? (string) $row['nationality_code'] : null,
            dateOfBirth: $row['date_of_birth'] !== null && $row['date_of_birth'] !== ''
                ? (string) $row['date_of_birth'] : null,
            passportNo: $row['passport_no'] !== null && $row['passport_no'] !== ''
                ? (string) $row['passport_no'] : null,
            passportIssueDate: $row['passport_issue_date'] !== null ? (string) $row['passport_issue_date'] : null,
            passportExpiryDate: $row['passport_expiry_date'] !== null ? (string) $row['passport_expiry_date'] : null,
            citizenIdNo: $row['citizen_id_no'] !== null && $row['citizen_id_no'] !== ''
                ? (string) $row['citizen_id_no'] : null,
            thResidenceEvidenceId: $row['th_residence_evidence_id'] !== null
                ? (string) $row['th_residence_evidence_id'] : null,
            deletedAt: $row['deleted_at'] !== null ? (string) $row['deleted_at'] : null,
            anonymizedAt: $row['anonymized_at'] !== null ? (string) $row['anonymized_at'] : null,
            createdAt: (string) $row['created_at'],
            updatedAt: (string) $row['updated_at'],
        );
    }
}
