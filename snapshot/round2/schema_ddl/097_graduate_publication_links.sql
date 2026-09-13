-- DDL extracted from 097_graduate_publication_links.sql (sha256 20ffcd8f9825e450eb0b5fa0e4cfa96dc7faafcf79cd711b36cb4dff4abcb08c)
ALTER TABLE graduates
    ADD COLUMN IF NOT EXISTS publication_doi VARCHAR(120) NULL COMMENT 'bare DOI, e.g. 10.1234/abcd — no https://doi.org/ prefix' AFTER publication_citation,
    ADD COLUMN IF NOT EXISTS publication_url VARCHAR(500) NULL COMMENT 'article URL when no DOI exists (e.g. TCI-Thaijo articles)' AFTER publication_doi;
