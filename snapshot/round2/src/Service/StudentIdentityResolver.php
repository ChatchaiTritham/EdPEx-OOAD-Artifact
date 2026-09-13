<?php
declare(strict_types=1);

namespace Edpex\Service;

use AppDB;
use Edpex\Domain\Student\AcademicDegreeRecord;
use Edpex\Domain\Student\StudentIdentity;
use Edpex\Domain\Student\UnifiedStudentProfile;
use Edpex\Security\PdpaCrypto;

/**
 * Domain Service responsible for resolving and linking multi-degree student profiles.
 */
final class StudentIdentityResolver
{
    private PdpaCrypto $crypto;

    public function __construct(?PdpaCrypto $crypto = null)
    {
        $this->crypto = $crypto ?? new PdpaCrypto();
    }

    /**
     * Resolve all degrees and full unified profile for a given student code.
     */
    public function resolveProfile(string $studentCode): ?UnifiedStudentProfile
    {
        $primaryRow = AppDB::one(
            "SELECT p.id, p.student_code, p.title, p.name_th, p.name_en, p.nationality_code,
                    p.date_of_birth, p.passport_no, p.citizen_id_no, p.email
               FROM th_ac_rmutk_ic_students p
              WHERE p.student_code = ? AND p.deleted_at IS NULL LIMIT 1",
            [$studentCode]
        );

        if ($primaryRow === null) {
            return null;
        }

        $dob = $this->decryptNullable($primaryRow['date_of_birth'] ?? null);
        $passport = $this->decryptNullable($primaryRow['passport_no'] ?? null);
        $citizen = $this->decryptNullable($primaryRow['citizen_id_no'] ?? null);

        $primaryIdentity = new StudentIdentity(
            personId: (string) $primaryRow['id'],
            studentCode: (string) $primaryRow['student_code'],
            nameEn: (string) ($primaryRow['name_en'] ?? ''),
            nameTh: (string) ($primaryRow['name_th'] ?? ''),
            passportNo: $passport,
            citizenId: $citizen,
            dateOfBirth: $dob,
            email: (string) ($primaryRow['email'] ?? '')
        );

        // Fetch candidate linked student records
        $candidateRows = $this->findCandidateRows($primaryIdentity);

        $degreeRecords = [];
        $seenCodes = [];

        foreach ($candidateRows as $r) {
            $code = (string) $r['student_code'];
            if (isset($seenCodes[$code])) {
                continue;
            }
            $seenCodes[$code] = true;

            $candDob = $this->decryptNullable($r['date_of_birth'] ?? null);
            $candPassport = $this->decryptNullable($r['passport_no'] ?? null);
            $candCitizen = $this->decryptNullable($r['citizen_id_no'] ?? null);

            $candIdentity = new StudentIdentity(
                personId: (string) $r['id'],
                studentCode: $code,
                nameEn: (string) ($r['name_en'] ?? ''),
                nameTh: (string) ($r['name_th'] ?? ''),
                passportNo: $candPassport,
                citizenId: $candCitizen,
                dateOfBirth: $candDob,
                email: (string) ($r['email'] ?? '')
            );

            // Verify identity match
            if ($code === $studentCode || $primaryIdentity->matches($candIdentity)) {
                $degreeRecords[] = new AcademicDegreeRecord(
                    personId: (string) $r['id'],
                    studentCode: $code,
                    degreeLevel: (string) ($r['level'] ?: ($r['level_section'] ?: '')),
                    programNameEn: (string) ($r['program'] ?: ''),
                    programNameTh: (string) ($r['program'] ?: ''),
                    admitYear: (int) ($r['admit_year'] ?: 0),
                    statusName: (string) ($r['status_name_th'] ?: ($r['student_status_code'] ?: 'Active')),
                    statusCode: (string) ($r['student_status_code'] ?: 'ACT'),
                    gpax: (float) ($r['gpa'] ?: 0.0),
                    creditsEarned: (int) ($r['credits_earned'] ?: 0),
                    advisorName: (string) ($r['advisor_name'] ?? ''),
                    campusName: (string) ($r['campus_name'] ?? ''),
                    facultyName: (string) ($r['faculty_name'] ?? '')
                );
            }
        }

        // Sort degrees chronologically (Bachelor -> Master -> Doctoral)
        usort($degreeRecords, function (AcademicDegreeRecord $a, AcademicDegreeRecord $b): int {
            if ($a->admitYear !== $b->admitYear) {
                return $a->admitYear <=> $b->admitYear;
            }
            $tierOrder = ['bachelor' => 1, 'master' => 2, 'doctoral' => 3, 'other' => 4];
            return ($tierOrder[$a->getDegreeTier()] ?? 99) <=> ($tierOrder[$b->getDegreeTier()] ?? 99);
        });

        return new UnifiedStudentProfile($primaryIdentity, $degreeRecords, $studentCode);
    }

    /**
     * Find candidate student rows based on name, passport, or citizen ID.
     * @return list<array<string,mixed>>
     */
    private function findCandidateRows(StudentIdentity $id): array
    {
        $sql = "SELECT p.id, p.student_code, p.title, p.name_th, p.name_en, p.nationality_code,
                       p.date_of_birth, p.passport_no, p.citizen_id_no, p.email,
                       e.program, e.level, e.level_section, e.section, e.admit_year, e.admit_semester,
                       e.student_status_code, e.credits_earned, e.gpa, e.advisor_name,
                       c.name_th AS campus_name, f.name_th AS faculty_name, s.status_name_th
                  FROM th_ac_rmutk_ic_students p
                  LEFT JOIN th_ac_rmutk_ic_student_enrollments e ON e.person_id = p.id
                  LEFT JOIN ref_campus c ON c.id = e.campus_id
                  LEFT JOIN ref_faculty f ON f.id = e.faculty_id
                  LEFT JOIN ref_student_status s ON s.status_code = e.student_status_code
                 WHERE p.deleted_at IS NULL
                   AND (p.student_code = ? OR p.name_en = ? OR p.name_th = ? OR p.email = ?)";

        $rows = AppDB::all($sql, [
            $id->studentCode,
            $id->nameEn,
            $id->nameTh,
            $id->email ?: '---'
        ]);

        // If passport is available, also search broader candidate set if needed
        if ($id->passportNo !== null && strlen($id->passportNo) >= 5) {
            $allStudents = AppDB::all(
                "SELECT p.id, p.student_code, p.title, p.name_th, p.name_en, p.nationality_code,
                        p.date_of_birth, p.passport_no, p.citizen_id_no, p.email,
                        e.program, e.level, e.level_section, e.section, e.admit_year, e.admit_semester,
                        e.student_status_code, e.credits_earned, e.gpa, e.advisor_name,
                        c.name_th AS campus_name, f.name_th AS faculty_name, s.status_name_th
                   FROM th_ac_rmutk_ic_students p
                   LEFT JOIN th_ac_rmutk_ic_student_enrollments e ON e.person_id = p.id
                   LEFT JOIN ref_campus c ON c.id = e.campus_id
                   LEFT JOIN ref_faculty f ON f.id = e.faculty_id
                   LEFT JOIN ref_student_status s ON s.status_code = e.student_status_code
                  WHERE p.deleted_at IS NULL"
            );
            $existingCodes = array_column($rows, 'student_code');
            foreach ($allStudents as $st) {
                if (in_array($st['student_code'], $existingCodes, true)) {
                    continue;
                }
                $decPass = $this->decryptNullable($st['passport_no'] ?? null);
                if ($decPass !== null && strcasecmp($decPass, $id->passportNo) === 0) {
                    $rows[] = $st;
                    $existingCodes[] = $st['student_code'];
                }
            }
        }

        return $rows;
    }

    private function decryptNullable(?string $val): ?string
    {
        if ($val === null || $val === '') {
            return null;
        }
        $dec = $this->crypto->decrypt($val);
        $clean = trim((string) $dec);
        return (str_starts_with($clean, 'enc:') || $clean === '') ? null : $clean;
    }
}
