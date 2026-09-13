<?php

declare(strict_types=1);

namespace Edpex\Admission\Repository;

use Edpex\Admission\Entity\Person;

/**
 * Contract only — PersonController depends on THIS, not the concrete PersonRepository, so it can
 * be unit-tested with a fake implementation instead of hitting real AppDB (the reason this
 * interface exists at all — see the OOA/OOD review).
 */
interface PersonRepositoryInterface
{
    public function find(string $id): ?Person;

    /** Blind-index lookup — the only way to find a person by passport number (the encrypted
     *  column itself is never equality-comparable). */
    public function findByPassportNo(string $passportNo): ?Person;

    /** Same blind-index detour as findByPassportNo(), for the home-country national ID/citizen-
     *  card number (schema/100). */
    public function findByCitizenIdNo(string $citizenIdNo): ?Person;

    /** student_code is plaintext (not L4, same tier as name_th/name_en) — a direct equality
     *  lookup, unlike findByPassportNo()'s blind-index detour. */
    public function findByStudentCode(string $studentCode): ?Person;

    /** @return list<Person> */
    public function listAll(int $limit = 50, int $offset = 0): array;

    /** Insert if $person->id is new, else update. Returns the (possibly newly assigned) id. */
    public function save(Person $person): string;
}
