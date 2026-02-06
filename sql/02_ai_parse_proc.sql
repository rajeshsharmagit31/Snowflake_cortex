USE DATABASE AI_GOV;
USE SCHEMA AI_AUTOMATION;

CREATE OR REPLACE PROCEDURE PROCESS_AI_GRANT_REQUESTS()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  MERGE INTO AI_GRANT_REQUESTS t
  USING (
    SELECT
      REQUEST_ID,
      AI_EXTRACT(
        text => PROMPT_TEXT,
        responseFormat => PARSE_JSON('{
          "schema": {
            "type": "object",
            "properties": {
              "role": {"type": "string", "description": "Role to receive the grant"},
              "database": {"type": "string", "description": "Target database name"},
              "privileges": {"type": "array", "description": "List of privileges like USAGE"}
            },
            "required": ["role", "database"]
          }
        }')
      ) AS EXTRACT
    FROM AI_GRANT_REQUESTS
    WHERE STATUS = 'NEW'
  ) s
  ON t.REQUEST_ID = s.REQUEST_ID
  WHEN MATCHED THEN UPDATE SET
    PARSED_JSON = s.EXTRACT:response,
    PARSE_ERROR = s.EXTRACT:error,
    STATUS = IFF(s.EXTRACT:error IS NULL, 'PARSED', 'FAILED');

  RETURN 'OK';
END;
$$;
