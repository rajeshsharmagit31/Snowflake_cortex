USE DATABASE AI_GOV;
USE SCHEMA AI_AUTOMATION;

-- Stage to export approved requests as JSON
CREATE OR REPLACE STAGE AI_GRANTS_STAGE;

-- Export approved requests into a single JSON file (JSON lines)
COPY INTO @AI_GRANTS_STAGE/approved_requests.json
FROM (
  SELECT OBJECT_CONSTRUCT(
    'request_id', REQUEST_ID,
    'role', PARSED_JSON:role::STRING,
    'database', PARSED_JSON:database::STRING,
    'privileges', PARSED_JSON:privileges
  )
  FROM AI_GRANT_REQUESTS
  WHERE STATUS = 'APPROVED'
)
FILE_FORMAT = (TYPE = JSON)
SINGLE = TRUE
OVERWRITE = TRUE;
