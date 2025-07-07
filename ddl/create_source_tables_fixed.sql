-- ========================================
-- DDL and Sample Data for PKG_SSP_TANK_DETAIL Testing
-- ========================================
-- Date: July 7, 2025
-- Purpose: Create source tables and populate with dummy data for testing

-- First, create and use the database
CREATE DATABASE IF NOT EXISTS ANALYTICS_DEV;
USE DATABASE ANALYTICS_DEV;

-- Create schemas if they don't exist
CREATE SCHEMA IF NOT EXISTS LND_MANUAL_ENTRY;
CREATE SCHEMA IF NOT EXISTS STG_EDW;

-- Set the schema context
USE SCHEMA LND_MANUAL_ENTRY;

-- ========================================
-- 1. LND_MANUAL_ENTRY.SSP_RR_CALENDAR
-- ========================================
-- This is the main source table for the tank detail processing

CREATE OR REPLACE TABLE SSP_RR_CALENDAR (
    CALENDAR_YEAR NUMBER(4) NOT NULL,
    CALENDAR_MONTH NUMBER(2) NOT NULL,
    ACTIVE_FLG VARCHAR(1) NOT NULL DEFAULT 'Y',

    -- Audit columns (Oracle style)
    CREATE_DT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    CREATE_BY VARCHAR(50) DEFAULT 'SYSTEM',
    CREATE_PGM VARCHAR(100) DEFAULT 'DDL_SETUP',
    UPDATE_DT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATE_BY VARCHAR(50) DEFAULT 'SYSTEM',
    UPDATE_PGM VARCHAR(100) DEFAULT 'DDL_SETUP',

    -- Primary key
    CONSTRAINT PK_SSP_RR_CALENDAR PRIMARY KEY (CALENDAR_YEAR, CALENDAR_MONTH)
);

-- Insert dummy data for testing (2023-2025)
INSERT INTO SSP_RR_CALENDAR (
    CALENDAR_YEAR,
    CALENDAR_MONTH,
    ACTIVE_FLG,
    CREATE_DT,
    CREATE_BY,
    CREATE_PGM
) VALUES
-- 2023 data
(2023, 1, 'Y', '2023-01-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 2, 'Y', '2023-02-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 3, 'Y', '2023-03-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 4, 'Y', '2023-04-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 5, 'Y', '2023-05-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 6, 'Y', '2023-06-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 7, 'Y', '2023-07-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 8, 'Y', '2023-08-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 9, 'Y', '2023-09-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 10, 'Y', '2023-10-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 11, 'Y', '2023-11-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2023, 12, 'Y', '2023-12-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),

-- 2024 data
(2024, 1, 'Y', '2024-01-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 2, 'Y', '2024-02-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 3, 'Y', '2024-03-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 4, 'Y', '2024-04-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 5, 'Y', '2024-05-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 6, 'Y', '2024-06-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 7, 'Y', '2024-07-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 8, 'Y', '2024-08-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 9, 'Y', '2024-09-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 10, 'Y', '2024-10-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 11, 'Y', '2024-11-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2024, 12, 'Y', '2024-12-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),

-- 2025 data (current year)
(2025, 1, 'Y', '2025-01-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 2, 'Y', '2025-02-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 3, 'Y', '2025-03-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 4, 'Y', '2025-04-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 5, 'Y', '2025-05-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 6, 'Y', '2025-06-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 7, 'Y', '2025-07-07'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'), -- Current date
(2025, 8, 'N', '2025-08-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'), -- Inactive for testing
(2025, 9, 'Y', '2025-09-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 10, 'Y', '2025-10-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 11, 'Y', '2025-11-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD'),
(2025, 12, 'Y', '2025-12-01'::TIMESTAMP, 'SETUP', 'DDL_INITIAL_LOAD');

-- ========================================
-- 2. Verification Queries
-- ========================================

-- Verify calendar data
SELECT
    'Calendar Records' AS TABLE_NAME,
    COUNT(*) AS RECORD_COUNT,
    MIN(CALENDAR_YEAR) AS MIN_YEAR,
    MAX(CALENDAR_YEAR) AS MAX_YEAR,
    SUM(CASE WHEN ACTIVE_FLG = 'Y' THEN 1 ELSE 0 END) AS ACTIVE_COUNT,
    SUM(CASE WHEN ACTIVE_FLG = 'N' THEN 1 ELSE 0 END) AS INACTIVE_COUNT
FROM SSP_RR_CALENDAR;

-- Show sample data
SELECT
    CALENDAR_YEAR,
    CALENDAR_MONTH,
    ACTIVE_FLG,
    CREATE_DT
FROM SSP_RR_CALENDAR
WHERE CALENDAR_YEAR = 2025
ORDER BY CALENDAR_MONTH;

-- Show all data summary
SELECT
    CALENDAR_YEAR,
    COUNT(*) AS MONTH_COUNT,
    SUM(CASE WHEN ACTIVE_FLG = 'Y' THEN 1 ELSE 0 END) AS ACTIVE_MONTHS,
    SUM(CASE WHEN ACTIVE_FLG = 'N' THEN 1 ELSE 0 END) AS INACTIVE_MONTHS
FROM SSP_RR_CALENDAR
GROUP BY CALENDAR_YEAR
ORDER BY CALENDAR_YEAR;

-- ========================================
-- 3. Additional Test Data (Optional)
-- ========================================
-- Use these commands to add more test data if needed

-- Add a few more records for incremental testing
/*
INSERT INTO SSP_RR_CALENDAR (
    CALENDAR_YEAR,
    CALENDAR_MONTH,
    ACTIVE_FLG,
    CREATE_DT,
    CREATE_BY,
    CREATE_PGM
) VALUES
(2026, 1, 'Y', CURRENT_TIMESTAMP(), 'TEST_USER', 'INCREMENTAL_TEST'),
(2026, 2, 'Y', CURRENT_TIMESTAMP(), 'TEST_USER', 'INCREMENTAL_TEST');
*/

-- ========================================
-- 4. Cleanup Commands (If Needed)
-- ========================================
-- Use these if you need to reset the environment

-- Drop table (uncomment if needed)
-- DROP TABLE IF EXISTS SSP_RR_CALENDAR;

-- Drop schema (uncomment if needed)
-- DROP SCHEMA IF EXISTS LND_MANUAL_ENTRY;

-- Drop database (uncomment if needed)
-- DROP DATABASE IF EXISTS ANALYTICS_DEV;

-- ========================================
-- 5. Grant Permissions (If Needed)
-- ========================================
-- Uncomment and modify these if you need to grant permissions

-- Grant permissions to a specific role
-- GRANT USAGE ON DATABASE ANALYTICS_DEV TO ROLE TRANSFORMER;
-- GRANT USAGE ON SCHEMA LND_MANUAL_ENTRY TO ROLE TRANSFORMER;
-- GRANT SELECT ON ALL TABLES IN SCHEMA LND_MANUAL_ENTRY TO ROLE TRANSFORMER;

-- Grant permissions to a specific user
-- GRANT USAGE ON DATABASE ANALYTICS_DEV TO USER your_dbt_user;
-- GRANT USAGE ON SCHEMA LND_MANUAL_ENTRY TO USER your_dbt_user;
-- GRANT SELECT ON ALL TABLES IN SCHEMA LND_MANUAL_ENTRY TO USER your_dbt_user;

-- ========================================
-- 6. Success Message
-- ========================================
SELECT
    'Setup completed successfully!' AS MESSAGE,
    CURRENT_TIMESTAMP() AS COMPLETED_AT,
    COUNT(*) AS TOTAL_RECORDS_CREATED
FROM SSP_RR_CALENDAR;
