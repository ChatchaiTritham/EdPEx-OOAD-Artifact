<?php

declare(strict_types=1);

namespace Edpex\Admission\Repository;

use Edpex\Admission\Entity\Person;
use Edpex\Security\PdpaCrypto;

/**
 * SQL lives here only — prepared statements via the existing AppDB static wrapper. Decrypts on the
 * way out, encrypts + computes blind indexes on the way in. Never decides WHO gets to see a
 * decrypted value — that's PersonAccessPolicy, one layer up (see the interface's docblock).
 */
final class PersonRepository implements PersonRepositoryInterface
{
    public function __construct(private readonly PdpaCrypto $crypto)
    {
    }

    public function find(string $id): ?Person
    {
        $row = \AppDB::one(
            'SELECT * FROM th_ac_rmutk_ic_students WHERE id = ? AND deleted_at IS NULL',
            [$id]
        );
        return $row === null ? null : $this->hydrate($row);
    }

    public function findByPassportNo(string $passportNo): ?Person
    {
        $bidx = $this->crypto->blindIndex($passportNo);
        if ($bidx === '') {
            return null; // no index key configured — can't look up, same as encrypt()'s dev no-op
        }
        $row = \AppDB::one(
            'SELECT * FROM th_ac_rmutk_ic_students WHERE passport_no_bidx = ? AND deleted_at IS NULL',
            [$bidx]
        );
        return $row === null ? null : $this->hydrate($row);
    }

    public function findByCitizenIdNo(string $citizenIdNo): ?Person
    {
        $bidx = $this->crypto->blindIndex($citizenIdNo);
        if ($bidx === '') {
            return null; // no index key configured — can't look up, same as encrypt()'s dev no-op
        }
        $row = \AppDB::one(
            'SELECT * FROM th_ac_rmutk_ic_students WHERE citizen_id_no_bidx = ? AND deleted_at IS NULL',
            [$bidx]
        );
        return $row === null ? null : $this->hydrate($row);
    }

    public function findByStudentCode(string $studentCode): ?Person
    {
        $row = \AppDB::one(
            'SELECT * FROM th_ac_rmutk_ic_students WHERE student_code = ? AND deleted_at IS NULL',
            [$studentCode]
        );
        return $row === null ? null : $this->hydrate($row);
    }

    public function listAll(int $limit = 50, int $offset = 0): array
    {
        $rows = \AppDB::all(
            'SELECT * FROM th_ac_rmutk_ic_students WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT ? OFFSET ?',
            [$limit, $offset]
        );
        return array_map($this->hydrate(...), $rows);
    }

    public function save(Person $person): string
    {
        \AppDB::exec(
            'INSERT INTO th_ac_rmutk_ic_students
                (id, tenant_id, student_code, title, name_th, name_en, nationality_code,
                 date_of_birth, passport_no, passport_no_bidx,
                 passport_issue_date, passport_expiry_date, citizen_id_no, citizen_id_no_bidx,
                 th_residence_evidence_id)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
             ON DUPLICATE KEY UPDATE
                student_code = VALUES(student_code),
                title = VALUES(title), name_th = VALUES(name_th), name_en = VALUES(name_en),
                nationality_code = VALUES(nationality_code),
                date_of_birth = VALUES(date_of_birth),
                passport_no = VALUES(passport_no), passport_no_bidx = VALUES(passport_no_bidx),
                passport_issue_date = VALUES(passport_issue_date),
                passport_expiry_date = VALUES(passport_expiry_date),
                citizen_id_no = VALUES(citizen_id_no), citizen_id_no_bidx = VALUES(citizen_id_no_bidx),
                th_residence_evidence_id = VALUES(th_residence_evidence_id)',
            [
                $person->id, $person->tenantId, $person->studentCode, $person->title,
                $person->nameTh, $person->nameEn, $person->nationalityCode,
                $person->dateOfBirth !== null ? $this->crypto->encrypt($person->dateOfBirth) : null,
                $person->passportNo !== null ? $this->crypto->encrypt($person->passportNo) : null,
                $person->passportNo !== null ? $this->crypto->blindIndex($person->passportNo) : null,
                $person->passportIssueDate, $person->passportExpiryDate,
                $person->citizenIdNo !== null ? $this->crypto->encrypt($person->citizenIdNo) : null,
                $person->citizenIdNo !== null ? $this->crypto->blindIndex($person->citizenIdNo) : null,
                $person->thResidenceEvidenceId,
            ]
        );
        return $person->id;
    }

    /** @param array<string,mixed> $row */
    private function hydrate(array $row): Person
    {
        $row['date_of_birth'] = $row['date_of_birth'] !== null
            ? $this->crypto->decrypt((string) $row['date_of_birth']) : null;
        $row['passport_no'] = $row['passport_no'] !== null
            ? $this->crypto->decrypt((string) $row['passport_no']) : null;
        $row['citizen_id_no'] = ($row['citizen_id_no'] ?? null) !== null
            ? $this->crypto->decrypt((string) $row['citizen_id_no']) : null;
        return Person::fromRow($row);
    }
}
