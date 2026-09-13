-- DDL extracted from 091_evidence_document_import.sql (sha256 0c143350151bff11c5f8d9e49a541f2d7baaa8b55ab54d19c65535e67223a70d)
ALTER TABLE ic_evidence_document
    MODIFY COLUMN doc_type ENUM(
        'passport_copy','visa_copy','work_permit','residence_proof','contract','transcript',
        'publication_proof','registration_form','rector_letter','unclassified'
    ) NOT NULL;
