<?php

declare(strict_types=1);

namespace Edpex\Admission\Controller;

use Edpex\Admission\Entity\Person;
use Edpex\Admission\Policy\PersonAccessPolicy;
use Edpex\Admission\Repository\PersonRepositoryInterface;
use Edpex\Admission\Repository\VisaRecordRepositoryInterface;
use Edpex\Admission\Support\JsonResponseTrait;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

final class PersonController
{
    use JsonResponseTrait;

    public function __construct(
        private readonly PersonRepositoryInterface $persons,
        private readonly VisaRecordRepositoryInterface $visaRecords,
        private readonly PersonAccessPolicy $policy,
    ) {
    }

    public function list(Request $request, Response $response): Response
    {
        $role = $this->callerRole($request);
        $q = $request->getQueryParams();
        $limit = min(200, max(1, (int) ($q['limit'] ?? 50)));
        $offset = max(0, (int) ($q['offset'] ?? 0));

        $people = $this->persons->listAll($limit, $offset);
        return $this->jsonOk($response, $this->policy->shapeAllFor($people, $role), count($people));
    }

    public function detail(Request $request, Response $response, array $args): Response
    {
        $role = $this->callerRole($request);
        $person = $this->persons->find((string) $args['id']);
        if ($person === null) {
            return $this->jsonError($response, 'NOT_FOUND', 'person not found', 404);
        }
        return $this->jsonOk($response, $this->policy->shapeFor($person, $role));
    }

    /** Read-only, metadata-first profile projection for the evidence workspace. */
    public function profile(Request $request, Response $response, array $args): Response
    {
        $personId = (string) $args['id'];
        $person = $this->persons->find($personId);
        if ($person === null) {
            return $this->jsonError($response, 'NOT_FOUND', 'person not found', 404);
        }

        $enrollment = \AppDB::one(
            "SELECT e.program, e.level, e.level_section, e.admit_year, e.admit_semester,
                    e.credits_earned, e.credits_registered, e.gpa, s.status_name_th, s.maps_to_enrollment_status
               FROM th_ac_rmutk_ic_student_enrollments e
               LEFT JOIN ref_student_status s ON s.status_code = e.student_status_code
              WHERE e.person_id = ?",
            [$personId]
        );
        $graduate = $person->studentCode === null ? null : \AppDB::one(
            'SELECT degree_level, program, entry_year, gcode, publication_title, publication_citation, publication_doi, publication_url, confidence
               FROM th_ac_rmutk_ic_graduates WHERE student_code = ?',
            [$person->studentCode]
        );
        $documents = \AppDB::all(
            'SELECT id, doc_type, status, uploaded_at, verified_at
               FROM th_ac_rmutk_ic_evidence_documents WHERE person_id = ? AND deleted_at IS NULL ORDER BY uploaded_at DESC',
            [$personId]
        );
        $byType = ['passport_copy' => 0, 'rector_letter' => 0, 'visa_copy' => 0, 'work_permit' => 0, 'other' => 0];
        $verified = 0;
        foreach ($documents as $document) {
            $type = (string) $document['doc_type'];
            $key = array_key_exists($type, $byType) ? $type : 'other';
            $byType[$key]++;
            $verified += $document['status'] === 'verified' ? 1 : 0;
        }

        return $this->jsonOk($response, [
            'person' => $this->policy->shapeFor($person, $this->callerRole($request)),
            'pregraduate' => $enrollment,
            'graduate' => $graduate,
            'graduate_data_gaps' => ['status' => true, 'grades' => true, 'thesis' => true],
            'visa_records' => array_map(static fn ($record): array => [
                'record_type' => $record->recordType, 'expiry_date' => $record->expiryDate,
            ], $this->visaRecords->listByPerson($personId)),
            'evidence' => ['documents' => $documents, 'by_type' => $byType, 'verified_count' => $verified, 'total' => count($documents)],
        ]);
    }

    public function create(Request $request, Response $response): Response
    {
        $body = (array) ($request->getParsedBody() ?? []);
        $passportNo = isset($body['passport_no']) ? (string) $body['passport_no'] : null;
        $studentCode = isset($body['student_code']) && $body['student_code'] !== ''
            ? (string) $body['student_code'] : null;

        $citizenIdNo = isset($body['citizen_id_no']) && $body['citizen_id_no'] !== ''
            ? (string) $body['citizen_id_no'] : null;

        if ($passportNo !== null && $this->persons->findByPassportNo($passportNo) !== null) {
            // same passport_no_bidx already on file — a real duplicate, not a silent second row (T4).
            return $this->jsonError($response, 'CONFLICT', 'a person with this passport_no already exists', 409);
        }
        if ($citizenIdNo !== null && $this->persons->findByCitizenIdNo($citizenIdNo) !== null) {
            return $this->jsonError($response, 'CONFLICT', 'a person with this citizen_id_no already exists', 409);
        }
        if ($studentCode !== null && $this->persons->findByStudentCode($studentCode) !== null) {
            // schema/093: student_code carries a real UNIQUE KEY now (the natural roster key,
            // more reliable than passport_no — 135/724 roster rows have no passport on file).
            return $this->jsonError($response, 'CONFLICT', 'a person with this student_code already exists', 409);
        }

        $nationalityCode = isset($body['nationality_code']) ? (string) $body['nationality_code'] : null;
        if (($err = $this->invalidNationalityCode($nationalityCode)) !== null) {
            return $this->jsonError($response, 'VALIDATION', $err, 422);
        }

        $person = new Person(
            id: appUuid(),
            tenantId: appTenant(),
            studentCode: $studentCode,
            title: isset($body['title']) ? (string) $body['title'] : null,
            nameTh: isset($body['name_th']) ? (string) $body['name_th'] : null,
            nameEn: isset($body['name_en']) ? (string) $body['name_en'] : null,
            nationalityCode: $nationalityCode,
            dateOfBirth: isset($body['date_of_birth']) ? (string) $body['date_of_birth'] : null,
            passportNo: $passportNo,
            passportIssueDate: isset($body['passport_issue_date']) ? (string) $body['passport_issue_date'] : null,
            passportExpiryDate: isset($body['passport_expiry_date']) ? (string) $body['passport_expiry_date'] : null,
            citizenIdNo: $citizenIdNo,
            thResidenceEvidenceId: null,
            deletedAt: null,
            anonymizedAt: null,
            createdAt: '',
            updatedAt: '',
        );
        $id = $this->persons->save($person);
        appAudit('create', 'students', $id);

        $saved = $this->persons->find($id);
        return $this->jsonOk($response, $saved !== null ? $this->policy->shapeFor($saved, $this->callerRole($request)) : ['id' => $id], null, 201);
    }

    public function update(Request $request, Response $response, array $args): Response
    {
        $existing = $this->persons->find((string) $args['id']);
        if ($existing === null) {
            return $this->jsonError($response, 'NOT_FOUND', 'person not found', 404);
        }
        $body = (array) ($request->getParsedBody() ?? []);

        $nationalityCode = array_key_exists('nationality_code', $body)
            ? (string) $body['nationality_code'] : $existing->nationalityCode;
        if (array_key_exists('nationality_code', $body) && ($err = $this->invalidNationalityCode($nationalityCode)) !== null) {
            return $this->jsonError($response, 'VALIDATION', $err, 422);
        }

        if (array_key_exists('student_code', $body)) {
            $studentCode = $body['student_code'] !== null && $body['student_code'] !== ''
                ? (string) $body['student_code'] : null;
        } else {
            $studentCode = $existing->studentCode;
        }
        if ($studentCode !== null && $studentCode !== $existing->studentCode) {
            $clash = $this->persons->findByStudentCode($studentCode);
            if ($clash !== null && $clash->id !== $existing->id) {
                return $this->jsonError($response, 'CONFLICT', 'a person with this student_code already exists', 409);
            }
        }

        $updated = new Person(
            id: $existing->id,
            tenantId: $existing->tenantId,
            studentCode: $studentCode,
            title: array_key_exists('title', $body) ? (string) $body['title'] : $existing->title,
            nameTh: array_key_exists('name_th', $body) ? (string) $body['name_th'] : $existing->nameTh,
            nameEn: array_key_exists('name_en', $body) ? (string) $body['name_en'] : $existing->nameEn,
            nationalityCode: $nationalityCode,
            dateOfBirth: array_key_exists('date_of_birth', $body) ? (string) $body['date_of_birth'] : $existing->dateOfBirth,
            passportNo: array_key_exists('passport_no', $body) ? (string) $body['passport_no'] : $existing->passportNo,
            passportIssueDate: array_key_exists('passport_issue_date', $body)
                ? (string) $body['passport_issue_date'] : $existing->passportIssueDate,
            passportExpiryDate: array_key_exists('passport_expiry_date', $body)
                ? (string) $body['passport_expiry_date'] : $existing->passportExpiryDate,
            citizenIdNo: array_key_exists('citizen_id_no', $body)
                ? (string) $body['citizen_id_no'] : $existing->citizenIdNo,
            thResidenceEvidenceId: $existing->thResidenceEvidenceId,
            deletedAt: $existing->deletedAt,
            anonymizedAt: $existing->anonymizedAt,
            createdAt: $existing->createdAt,
            updatedAt: '',
        );
        $this->persons->save($updated);
        appAudit('update', 'students', $existing->id);

        $saved = $this->persons->find($existing->id);
        return $this->jsonOk($response, $saved !== null ? $this->policy->shapeFor($saved, $this->callerRole($request)) : null);
    }

    /** GET /visa-expiring?days=30 — deliberately on PersonController per the design doc's routes
     *  table (a worklist keyed by person, not a visa-record CRUD action). */
    public function expiring(Request $request, Response $response): Response
    {
        $days = max(1, (int) ($request->getQueryParams()['days'] ?? 30));
        $records = $this->visaRecords->listExpiring($days);

        $role = $this->callerRole($request);
        $seen = [];
        $worklist = [];
        foreach ($records as $record) {
            $person = $seen[$record->personId] ??= $this->persons->find($record->personId);
            $worklist[] = [
                'person' => $person !== null ? $this->policy->shapeFor($person, $role) : null,
                'record_type' => $record->recordType,
                'expiry_date' => $record->expiryDate,
            ];
        }
        return $this->jsonOk($response, $worklist, count($worklist));
    }

    private function callerRole(Request $request): string
    {
        $user = $request->getAttribute('auth_user');
        return is_array($user) ? (string) ($user['role_code'] ?? 'viewer') : 'viewer';
    }

    /** nationality_code is a free-typed FK to ref_country (no DB constraint, per this project's
     *  convention) — checked here so a typo doesn't silently land in students and only
     *  surface later as a broken join. Empty/absent is valid (optional field). Returns an error
     *  message, or null when the code is fine. */
    private function invalidNationalityCode(?string $code): ?string
    {
        if ($code === null || $code === '') {
            return null;
        }
        // AppDB::scalar() wraps PDO::fetchColumn(), which returns false (not null) on no match.
        $exists = (bool) \AppDB::scalar('SELECT 1 FROM ref_country WHERE code = ?', [$code]);
        return $exists ? null : "unknown nationality_code '{$code}' — not found in ref_country";
    }
}
