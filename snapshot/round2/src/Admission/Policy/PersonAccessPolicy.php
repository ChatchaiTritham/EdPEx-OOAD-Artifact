<?php

declare(strict_types=1);

namespace Edpex\Admission\Policy;

use Edpex\Admission\Entity\Person;

/**
 * "Never return a decrypted L4 field to a role below manage_admin" lives HERE, not in
 * PersonRepository — a business/authorization rule inside a data-access class gives that class
 * two reasons to change (how Person data is queried, and who's allowed to see which field), a
 * Single-Responsibility violation caught in the OOA/OOD review. PersonRepository always returns
 * the full decrypted entity; this class decides what a given caller is shown.
 *
 * Fail-closed by construction: the default shape omits L4 fields — a caller only sees them if
 * explicitly entitled, never because someone forgot to redact.
 *
 * BUG FIXED 2026-08-15 (found during live verification, not just code reading): this used to hard-
 * code a role-code allowlist (`['manage_admin', 'admin']`) — but `manage_admin` is a CAPABILITY
 * code, not a role code (there is no role literally named that), and real roles carrying it —
 * `executive`, `SCIUTK_DEAN`, `SCIUTK_SUPER_ADMIN` — were silently excluded, meaning legitimate
 * callers would have had their own PII redacted. RbacMiddleware already gets this right via the
 * DB-driven `apiUserHasCapability()`; this class now calls the exact same function instead of
 * re-guessing role names, so there is one source of truth for "can this role see L4 data" project-
 * wide, not two that can drift apart.
 */
final class PersonAccessPolicy
{

    /** @return array<string,mixed> */
    public function shapeFor(Person $person, string $role): array
    {
        $shaped = [
            'id' => $person->id,
            'student_code' => $person->studentCode,
            'title' => $person->title,
            'name_th' => $person->nameTh,
            'name_en' => $person->nameEn,
            'nationality_code' => $person->nationalityCode,
            'passport_issue_date' => $person->passportIssueDate,
            'passport_expiry_date' => $person->passportExpiryDate,
            'created_at' => $person->createdAt,
            'updated_at' => $person->updatedAt,
        ];

        if ($this->canSeeL4($role)) {
            $shaped['date_of_birth'] = $person->dateOfBirth;
            $shaped['passport_no'] = $person->passportNo;
            $shaped['citizen_id_no'] = $person->citizenIdNo;
        }

        return $shaped;
    }

    /** @param list<Person> $people @return list<array<string,mixed>> */
    public function shapeAllFor(array $people, string $role): array
    {
        return array_map(fn (Person $p) => $this->shapeFor($p, $role), $people);
    }

    public function canSeeL4(string $role): bool
    {
        return apiUserHasCapability($role, 'manage_admin');
    }
}
