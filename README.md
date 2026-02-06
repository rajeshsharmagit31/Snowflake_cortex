# Snowflake Cortex Terraform

## Setup

This repo uses `tfenv` to manage Terraform versions and the Snowflake Terraform provider.

1. Install `tfenv` on your machine.
2. Copy the example vars file and update as needed.

```bash
cp terraform.tfvars.example terraform.tfvars
```

3. Install and select the pinned Terraform version.

```bash
make tfenv
```

4. Initialize Terraform.

```bash
terraform init
```

The pinned version lives in `.terraform-version`.

## Snowflake Provider

The provider is configured via variables in `variables.tf` and example values in
`terraform.tfvars.example`. The defaults match `externalbrowser` auth and the
provided account/role settings.

## AI Grant Automation (Option A)

This flow uses Snowflake Cortex to parse free‑text prompts into structured JSON, then Terraform applies approved grants.

1. Run the setup SQL to create the request table and parsing procedure.

```bash
snowsql -a KJNBWXI-ZW90463 -u RAJESHSNOWFLAKE31 -r ACCOUNTADMIN -f sql/01_ai_requests.sql
snowsql -a KJNBWXI-ZW90463 -u RAJESHSNOWFLAKE31 -r ACCOUNTADMIN -f sql/02_ai_parse_proc.sql
```

2. (Optional) Create and enable the parsing task after editing the warehouse in `sql/03_ai_parse_task.sql`.

```bash
snowsql -a KJNBWXI-ZW90463 -u RAJESHSNOWFLAKE31 -r ACCOUNTADMIN -f sql/03_ai_parse_task.sql
```

3. Insert a prompt request.

```sql
INSERT INTO AI_GOV.AI_AUTOMATION.AI_GRANT_REQUESTS (REQUESTED_BY, PROMPT_TEXT)
VALUES ('rajesh', 'grant ANALYST_ROLE usage on database SALES_DB');
```

4. Approve a parsed request.

```sql
UPDATE AI_GOV.AI_AUTOMATION.AI_GRANT_REQUESTS
SET STATUS = 'APPROVED', APPROVED_BY = 'rajesh', APPROVED_AT = CURRENT_TIMESTAMP()
WHERE REQUEST_ID = 1;
```

5. Export approved requests to a stage (JSON lines), then download to `data/approved_requests.json`.

```bash
snowsql -a KJNBWXI-ZW90463 -u RAJESHSNOWFLAKE31 -r ACCOUNTADMIN -f sql/04_export_approved.sql
snowsql -a KJNBWXI-ZW90463 -u RAJESHSNOWFLAKE31 -r ACCOUNTADMIN -q "GET @AI_GOV.AI_AUTOMATION.AI_GRANTS_STAGE/approved_requests.json file://$PWD/data/" -o exit_on_error=true
```

6. Convert exported JSON lines into Terraform resources.

```bash
python3 scripts/requests_to_tf.py data/approved_requests.json grants.auto.tf.json
```

7. Run Terraform plan/apply.

```bash
terraform plan
terraform apply
```

Notes:
- Cortex usage requires `SNOWFLAKE.CORTEX_USER` granted to the role running parsing.
- The parser is defined in `sql/02_ai_parse_proc.sql` and expects `role`, `database`, and optional `privileges`.
- The generated Terraform resources use `snowflake_database_grant` and default to `USAGE` if no privilege is provided.
