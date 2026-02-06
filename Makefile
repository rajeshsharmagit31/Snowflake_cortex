.PHONY: tfenv ai-setup ai-parse ai-task ai-export

SNOWSQL ?= snowsql
SNOWSQL_ARGS ?=

# Install and select the Terraform version pinned in .terraform-version
tfenv:
	@tfenv install
	@tfenv use

# Snowflake AI automation setup
ai-setup:
	@$(SNOWSQL) $(SNOWSQL_ARGS) -f sql/01_ai_requests.sql
	@$(SNOWSQL) $(SNOWSQL_ARGS) -f sql/02_ai_parse_proc.sql

# Create/enable the parsing task (edit warehouse in sql/03_ai_parse_task.sql first)
ai-task:
	@$(SNOWSQL) $(SNOWSQL_ARGS) -f sql/03_ai_parse_task.sql

# Export approved requests to a stage
ai-export:
	@$(SNOWSQL) $(SNOWSQL_ARGS) -f sql/04_export_approved.sql
