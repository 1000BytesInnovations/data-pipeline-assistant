# PKG_SSP_TANK_DETAIL Testing Setup Guide

## 🚀 Quick Start (5 Minutes)

### Prerequisites

- Snowflake account with appropriate permissions

- PowerShell (Windows) or equivalent shell access

- SnowSQL installed (optional, for automatic DDL execution)

### Step 1: Set Up Snowflake Environment

```powershell

# Run the setup script with your Snowflake credentials

.\setup_snowflake_env.ps1 -SnowflakeAccount "your_account.region" -SnowflakeUser "your_username" -SnowflakePassword "your_password"

```bash

### Alternative (Manual Environment Setup):

```powershell

$env:SNOWFLAKE_ACCOUNT = "your_account.region"
$env:SNOWFLAKE_USER = "your_username"
$env:SNOWFLAKE_PASSWORD = "your_password"
$env:SNOWFLAKE_ROLE = "TRANSFORMER"
$env:SNOWFLAKE_DATABASE = "ANALYTICS_DEV"
$env:SNOWFLAKE_WAREHOUSE = "COMPUTE_WH"
$env:SNOWFLAKE_SCHEMA = "DBT_DEV"

```bash

### Step 2: Create Source Tables (If Not Done Automatically)

If the setup script couldn't run SnowSQL automatically, execute the DDL manually:

### Option A: Using SnowSQL

```bash

snowsql -a your_account.region -u your_username -p your_password -f ddl/create_source_tables.sql

```bash

### Option B: Using Snowflake UI
Copy and paste the contents of `ddl/create_source_tables.sql` into the Snowflake worksheet and execute.

### Step 3: Run the Pipeline

```powershell

# Test the complete pipeline

.\test_pipeline.ps1

# Or run individual steps

cd dbt_project
dbt run --models pkg_ssp_tank_detail
dbt test --models pkg_ssp_tank_detail

```bash

## 🔄 Understanding Incremental Behavior

### First Run (Full Refresh)

- All models process complete dataset

- Creates baseline data in target tables

- Establishes incremental watermarks

### Subsequent Runs (Incremental)

- **Staging models**: Always full refresh (Oracle pattern: TRUNCATE + INSERT)

- **Intermediate models**: Full refresh (Oracle pattern: TRUNCATE + INSERT)

- **Oracle package model**: Incremental processing based on `calendar_year` and `update_dt`

- **Mart models**: Incremental processing based on source update timestamps

### Testing Incremental Behavior

1. **Run pipeline first time**: `.\test_pipeline.ps1`

2. **Add new source data**:

   ```sql

   INSERT INTO LND_MANUAL_ENTRY.SSP_RR_CALENDAR (CALENDAR_YEAR, CALENDAR_MONTH, ACTIVE_FLG)
   VALUES (2026, 1, 'Y');
   ```bash

3. **Run pipeline again**: `.\test_pipeline.ps1` (should process only new data)

4. **Force full refresh**: `.\test_pipeline.ps1 -FullRefresh`

## 📊 Data Flow Verification

### Check Source Data

```sql

SELECT calendar_year, calendar_month, active_flg, create_dt
FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR
ORDER BY calendar_year, calendar_month;

```bash

### Check Final Output

```sql

SELECT calendar_year, processing_type, variety_classification, final_calculation
FROM [target_schema].TANK_DETAIL_CONSOLIDATED
ORDER BY calendar_year;

```bash

### Check BIMA Processing

```sql

SELECT calendar_year, bima_season_type, bima_risk_category, bima_compliance_status
FROM [target_schema].TANK_DETAIL_BIMA
ORDER BY calendar_year;

```bash

## 🧪 Testing Scenarios

### Scenario 1: Normal Processing

- Source has active records (`ACTIVE_FLG = 'Y'`)

- All models should process successfully

- Expect data in all mart tables

### Scenario 2: Inactive Processing

- Set `ACTIVE_FLG = 'N'` for some records

- Pipeline should skip those records

- Verify control flow logic

### Scenario 3: Data Quality Issues

- Insert invalid data (e.g., `CALENDAR_MONTH = 13`)

- dbt tests should catch and report issues

- Review test results for data quality validation

### Scenario 4: Incremental Processing

- Add new calendar records

- Run pipeline again

- Verify only new data is processed

## 🐛 Troubleshooting

### Common Issues

### 1. Environment Variables Not Set

```bash

Error: Env var required but not provided: 'SNOWFLAKE_ACCOUNT'

```bash

**Solution**: Run `setup_snowflake_env.ps1` or set variables manually

### 2. Source Tables Don't Exist

```bash

Error: Object 'LND_MANUAL_ENTRY.SSP_RR_CALENDAR' does not exist

```bash

**Solution**: Execute `ddl/create_source_tables.sql` in Snowflake

### 3. Permission Issues

```bash

Error: Insufficient privileges to operate on schema 'LND_MANUAL_ENTRY'

```bash

**Solution**: Ensure your role has CREATE/INSERT/SELECT permissions

### 4. Incremental Logic Not Working

```bash

All data being processed on every run

```bash

**Solution**: Check that `unique_key` and incremental conditions are correct

### Debug Commands

```powershell

# Check dbt project structure

dbt ls --models pkg_ssp_tank_detail

# Compile models without running

dbt compile --models pkg_ssp_tank_detail

# Show compiled SQL

dbt show --select tank_detail_consolidated --compiled

# Run specific model only

dbt run --select stg_ssp_rr_calendar

# Test specific model only

dbt test --select tank_detail_consolidated

```bash

## 📈 Performance Monitoring

### Monitor Incremental Efficiency

- First run: Should process ~36 records (3 years of monthly data)

- Subsequent runs: Should process only new/changed records

- Check dbt logs for "X records processed" messages

### Check Model Lineage

```bash

dbt docs generate
dbt docs serve

# Navigate to model lineage in the documentation

```bash

## ✅ Success Criteria

### Pipeline is working correctly when:

1. ✅ All 8 models run successfully

2. ✅ All data quality tests pass

3. ✅ Source data flows through all transformation layers

4. ✅ Incremental processing works (subsequent runs process less data)

5. ✅ Business logic produces expected results

6. ✅ BIMA processing creates specialized output

7. ✅ Oracle package model replicates original logic

### Expected Output Counts (with test data):

- Source calendar: 36 records (2023-2025, 12 months each)

- Staging: 35 active records (1 inactive month)

- Final marts: Aggregated data based on business logic
