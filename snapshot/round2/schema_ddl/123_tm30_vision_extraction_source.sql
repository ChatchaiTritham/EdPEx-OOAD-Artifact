-- DDL extracted from 123_tm30_vision_extraction_source.sql (sha256 56bbfc2dac779e38879f3e297e2c60456f0e8bc9247c8fbe0ff24a0b6a367920)
ALTER TABLE ic_tm30_record
    MODIFY COLUMN extraction_source ENUM('text_layer','ocr','vision') NOT NULL;
