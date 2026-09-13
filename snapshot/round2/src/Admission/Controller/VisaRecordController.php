<?php

declare(strict_types=1);

namespace Edpex\Admission\Controller;

use Edpex\Admission\Entity\VisaRecord;
use Edpex\Admission\Policy\PersonAccessPolicy;
use Edpex\Admission\Repository\VisaRecordRepositoryInterface;
use Edpex\Admission\Support\JsonResponseTrait;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

final class VisaRecordController
{
    use JsonResponseTrait;

    public function __construct(
        private readonly VisaRecordRepositoryInterface $visaRecords,
        private readonly PersonAccessPolicy $policy,
    ) {
    }

    public function list(Request $request, Response $response): Response
    {
        $personId = (string) ($request->getQueryParams()['person_id'] ?? '');
        if ($personId === '') {
            return $this->jsonError($response, 'BAD_REQUEST', 'person_id query param is required', 400);
        }
        $records = $this->visaRecords->listByPerson($personId);
        $role = $this->callerRole($request);
        return $this->jsonOk($response, array_map(fn (VisaRecord $r) => $this->shape($r, $role), $records), count($records));
    }

    private function callerRole(Request $request): string
    {
        $user = $request->getAttribute('auth_user');
        return is_array($user) ? (string) ($user['role_code'] ?? 'viewer') : 'viewer';
    }

    public function create(Request $request, Response $response): Response
    {
        $body = (array) ($request->getParsedBody() ?? []);
        $recordType = (string) ($body['record_type'] ?? '');
        $docNumber = (string) ($body['doc_number'] ?? '');
        $personId = (string) ($body['person_id'] ?? '');

        if (!in_array($recordType, ['visa', 'work_permit'], true) || $docNumber === '' || $personId === '') {
            return $this->jsonError($response, 'BAD_REQUEST', 'person_id, record_type (visa|work_permit), doc_number are required', 400);
        }
        if ($this->visaRecords->findByDocNumber($recordType, $docNumber) !== null) {
            // same (record_type, doc_number_bidx) already on file — real duplicate, not a silent second row (T4).
            return $this->jsonError($response, 'CONFLICT', 'a record with this doc_number already exists', 409);
        }

        $record = new VisaRecord(
            id: appUuid(),
            tenantId: appTenant(),
            personId: $personId,
            recordType: $recordType,
            docNumber: $docNumber,
            issueDate: isset($body['issue_date']) ? (string) $body['issue_date'] : null,
            expiryDate: isset($body['expiry_date']) ? (string) $body['expiry_date'] : null,
            evidenceDocumentId: isset($body['evidence_document_id']) ? (string) $body['evidence_document_id'] : null,
            deletedAt: null,
            createdAt: '',
        );
        $id = $this->visaRecords->save($record);
        appAudit('create', 'visa_records', $id);

        return $this->jsonOk($response, $this->shape($record, $this->callerRole($request)), null, 201);
    }

    /**
     * doc_number is L4 (same tier as Person::passportNo/citizenIdNo) — redact unless the caller
     * holds manage_admin, reusing PersonAccessPolicy::canSeeL4() as the single source of truth
     * for that check (not a second hard-coded role/capability test here). GET /visa-records and
     * /visa-expiring moved out of the manage_admin-gated route group onto Auth-only (any logged-in
     * role down to subject/IC_SUBJECT can call them) — this redaction is what makes that safe.
     */
    private function shape(VisaRecord $record, string $role): array
    {
        return [
            'id' => $record->id,
            'person_id' => $record->personId,
            'record_type' => $record->recordType,
            'doc_number' => $this->policy->canSeeL4($role) ? $record->docNumber : null,
            'issue_date' => $record->issueDate,
            'expiry_date' => $record->expiryDate,
            'evidence_document_id' => $record->evidenceDocumentId,
        ];
    }
}
