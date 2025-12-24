#!/usr/bin/env bash

# set -euo pipefail

# -----------------------------
# Configuration / Arguments
# -----------------------------
# SQL_DIR="testclient"                  # Subfolder containing .sql files
WHITELIST_REGEX="test_view.sql"            # Regex of files to include
BLACKLIST_REGEX="${3:-$^}"            # Regex of files to exclude (matches nothing by default)
BQ_PROJECT="mentor-development"           # Optional: set via env var
BQ_DATASET="testclient"           # Optional: set via env var
SQL_DIR=$BQ_DATASET

# -----------------------------
# Validation
# -----------------------------
if [[ ! -d "$SQL_DIR" ]]; then
  echo "Error: Directory '$SQL_DIR' does not exist."
  exit 1
fi

if ! command -v bq >/dev/null 2>&1; then
  echo "Error: 'bq' command not found. Install and authenticate BigQuery CLI."
  exit 1
fi

# -----------------------------
# Execution
# -----------------------------
echo "Scanning directory: $SQL_DIR"
echo "Whitelist regex: $WHITELIST_REGEX"
echo "Blacklist regex: $BLACKLIST_REGEX"
echo

shopt -s nullglob

for sql_file in "$SQL_DIR"/*.sql; do
  file_name="$(basename "$sql_file")"

  # Apply whitelist
  if ! [[ "$file_name" =~ $WHITELIST_REGEX ]]; then
    continue
  fi

  # Apply blacklist
  if [[ "$file_name" =~ $BLACKLIST_REGEX ]]; then
    continue
  fi

  echo "Executing SQL query from file $file_name:"

  sql_query=$(sed "s/{{ *clientId *}}/$BQ_DATASET/g" $sql_file) # | \
  echo "$sql_query"
  # bq query \
  #   --use_legacy_sql=false \
  #   --project_id="$BQ_PROJECT" \
  #   < "$sql_file"

  echo "Finished: $file_name"
  echo
done

echo "All matching SQL files processed."


