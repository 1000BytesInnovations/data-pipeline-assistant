# Snowflake Source Tables Setup Guide

## Overview

This guide explains how to create the source tables in Snowflake needed to test the PKG_SSP_TANK_DETAIL dbt models.

## Prerequisites

### 1. Snowflake Account

- Active Snowflake account with permissions to create databases and schemas

- User with at least the following roles: `TRANSFORMER`, `SYSADMIN`, or equivalent

### 2. SnowSQL Installation

- Download from: <https://developers.snowflake.com/snowsql/>

- Install and add to system PATH

- Test installation: `snowsql --version`

### 3. Required Information

- **Account Name**: Your Snowflake account identifier (e.g., `abc123.snowflakecomputing.com`)

- **Username**: Your Snowflake username

- **Password**: Your Snowflake password

- **Role**: Database role with creation permissions (default: `TRANSFORMER`)

- **Warehouse**: Compute warehouse to use (default: `COMPUTE_WH`)

## Source Tables Created

### LND_MANUAL_ENTRY.SSP_RR_CALENDAR

This is the main source table for the PKG_SSP_TANK_DETAIL pipeline.

### Schema

```sql

CREATE TABLE LND_MANUAL_ENTRY.SSP_RR_CALENDAR (
    CALENDAR_YEAR NUMBER(4) NOT NULL,
    CALENDAR_MONTH NUMBER(2) NOT NULL,
    ACTIVE_FLG VARCHAR(1) NOT NULL DEFAULT 'Y',

    -- Oracle-style audit columns

    CREATE_DT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CREATE_BY VARCHAR(50) DEFAULT 'SYSTEM',
    CREATE_PGM VARCHAR(100) DEFAULT 'DDL_SETUP',
    UPDATE_DT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_BY VARCHAR(50) DEFAULT 'SYSTEM',
    UPDATE_PGM VARCHAR(100) DEFAULT 'DDL_SETUP',

    CONSTRAINT PK_SSP_RR_CALENDAR PRIMARY KEY (CALENDAR_YEAR, CALENDAR_MONTH)
);

```bash

### Test Data:

- 36 records covering 2023-2025

- Mix of active ('Y') and inactive ('N') flags

- One inactive record (2025-08) for testing control logic

## Setup Methods

### Method 1: Automated Setup (Recommended)

Use the PowerShell script to automatically create tables:

```powershell

# Basic usage

.\create_snowflake_sources.ps1 -SnowflakeAccount 'your_account' -SnowflakeUser 'your_user' -SnowflakePassword 'your_password'

# With custom parameters

.\create_snowflake_sources.ps1 `
    -SnowflakeAccount 'abc123.snowflakecomputing.com' `
    -SnowflakeUser 'myuser' `
    -SnowflakePassword 'mypass' `
    -SnowflakeRole 'TRANSFORMER' `
    -SnowflakeDatabase 'ANALYTICS_DEV' `
    -SnowflakeWarehouse 'COMPUTE_WH' `
    -UseFixed

```bash

### Parameters:

- `-SnowflakeAccount`: Your Snowflake account name

- `-SnowflakeUser`: Your Snowflake username

- `-SnowflakePassword`: Your Snowflake password

- `-SnowflakeRole`: Database role (default: TRANSFORMER)

- `-SnowflakeDatabase`: Target database (default: ANALYTICS_DEV)

- `-SnowflakeWarehouse`: Compute warehouse (default: COMPUTE_WH)

- `-UseFixed`: Use the fixed DDL script (recommended)

- `-TestConnection`: Test connection without running DDL

### Method 2: Manual Setup

If you prefer to run the DDL manually:

1. **Connect to Snowflake:**

   ```bash

   snowsql --accountname your_account --username your_user
   ```bash

2. **Run DDL script:**

   ```sql

   -- Copy and paste the content from ddl/create_source_tables_fixed.sql

   -- Or use the file directly:

   ```bash

   ```bash

   snowsql --accountname your_account --username your_user -f ddl/create_source_tables_fixed.sql
   ```bash

### Method 3: Using the Setup Script

For a complete environment setup:

```powershell

.\setup_snowflake_env.ps1 `
    -SnowflakeAccount 'your_account' `
    -SnowflakeUser 'your_user' `
    -SnowflakePassword 'your_password'

```bash

## Verification

After creating the tables, verify the setup:

### 1. Check Table Creation

```sql

-- Verify table exists

SHOW TABLES IN SCHEMA LND_MANUAL_ENTRY;

-- Check table structure

DESC TABLE LND_MANUAL_ENTRY.SSP_RR_CALENDAR;

```bash

### 2. Verify Data

```sql

-- Check record count

SELECT COUNT(*) FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR;
-- Expected: 36 records

-- Check active/inactive distribution

SELECT
    active_flg,
    COUNT(*) as count
FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR
GROUP BY active_flg;
-- Expected: 35 active ('Y'), 1 inactive ('N')

-- Sample data

SELECT * FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR

WHERE calendar_year = 2025
ORDER BY calendar_month;

```bash

### 3. Test dbt Connection

```bash

cd dbt_project
dbt debug
dbt run --models stg_ssp_rr_calendar

```bash

## Testing the Pipeline

### 1. Basic Pipeline Test

```bash

cd dbt_project

# Parse project

dbt parse

# Test source freshness

dbt source freshness

# Run staging models

dbt run --models staging.pkg_ssp_tank_detail

# Run all models

dbt run --models pkg_ssp_tank_detail

# Run tests

dbt test --models pkg_ssp_tank_detail

```bash

### 2. Test Incremental Behavior

```bash

# First run (full refresh)

dbt run --models oracle_pkg_tank_detail_pipeline

# Add new data to source table

# (Insert new records into LND_MANUAL_ENTRY.SSP_RR_CALENDAR)

# Second run (incremental)

dbt run --models oracle_pkg_tank_detail_pipeline

```bash

### 3. Full Pipeline Test

```bash

# Run the comprehensive test script

.\test_pipeline.ps1

```bash

## Troubleshooting

### Common Issues

1. **Connection Failures**

   - Verify account name format (include `.snowflakecomputing.com`)

   - Check username/password

   - Ensure role has necessary permissions

2. **Permission Errors**

   - Grant CREATE privileges on database

   - Verify role can create schemas and tables

3. **DDL Execution Errors**

   - Check if database already exists

   - Verify schema permissions

   - Review error messages for specific issues

### Debug Commands

```powershell

# Test connection only

.\create_snowflake_sources.ps1 -SnowflakeAccount 'xxx' -SnowflakeUser 'xxx' -SnowflakePassword 'xxx' -TestConnection

# Check dbt configuration

cd dbt_project
dbt debug

# Parse dbt project

dbt parse

```bash

### Getting Help

1. Check the PowerShell script output for specific error messages

2. Review the DDL files in the `ddl/` directory

3. Verify your Snowflake permissions and role assignments

4. Test with a simple query first:

   ```sql

   SELECT CURRENT_DATABASE(), CURRENT_SCHEMA(), CURRENT_ROLE();
   ```bash

## Next Steps

After successfully creating the source tables:

1. **Run dbt models** to verify the pipeline works

2. **Execute tests** to validate data quality

3. **Monitor performance** of incremental models

4. **Add more test data** to validate edge cases

5. **Document business logic** for the converted models

## File Locations

- **DDL Scripts**: `ddl/create_source_tables.sql`, `ddl/create_source_tables_fixed.sql`

- **Setup Scripts**: `setup_snowflake_env.ps1`, `create_snowflake_sources.ps1`

- **Test Scripts**: `test_pipeline.ps1`

- **dbt Models**: `dbt_project/models/staging/pkg_ssp_tank_detail/`

- **Source Configuration**: `dbt_project/models/staging/pkg_ssp_tank_detail/schema.yml`
