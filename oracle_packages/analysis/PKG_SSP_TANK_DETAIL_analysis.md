# PKG_SSP_TANK_DETAIL Oracle Package Analysis

## Overview

**Package Name:** PKG_SSP_TANK_DETAIL
**Context:** PRODUCTION
**Purpose:** Tank detail data processing pipeline for SSP (Structured Software Process) system

## Data Flow Analysis

### Source Tables

1. **LND_MANUAL_ENTRY.SSP_RR_CALENDAR** - Calendar reference data

2. **STG_EDW.SSP_TANK_DETAIL_SRCVALID_01_VW** - Source validation view

3. **STG_EDW.SSP_TANK_DETAIL_BLND_EXP_02_VW** - Blend expression view

4. **STG_EDW.SSP_TANK_DETAIL_BY_APP_03_VW** - By application view

5. **STG_EDW.SSP_TANK_DETAIL_BY_VRTY_04_VW** - By variety view

### Target Tables

1. **STG_EDW.SSP_TANK_DETAIL_SRCVALID_01** - Source validation staging

2. **STG_EDW.SSP_TANK_DETAIL_BLND_EXP_02** - Blend expression staging

3. **STG_EDW.SSP_TANK_DETAIL_BY_APP_03** - By application staging

4. **STG_EDW.SSP_TANK_DETAIL_BY_VRTY_04** - By variety staging

5. **LND_MANUAL_ENTRY.SSP_TANK_DETAIL** - Final tank detail table

6. **LND_MANUAL_ENTRY.SSP_TANK_DETAIL_BIMA** - BIMA tank detail table

## Process Flow Sequence

### Step 0: Control Flow Check

- **Step Name:** p_SSP_TANK_DETAIL_TRUE_FALSE_REF

- **Purpose:** Check if process should run based on ACTIVE_FLG

- **Logic:** `SELECT CASE WHEN ACTIVE_FLG='Y' THEN 'TRUE' ELSE 'FALSE' END FROM LND_MANUAL_ENTRY.SSP_RR_CALENDAR`

### Step 1: Evaluation

- **Step Name:** p_SSP_TANK_DETAIL_TRUE_FALSE_EVAL

- **Purpose:** Evaluate control condition

### Step 2: Partition Management

- **Step Name:** p_SSP_TANK_DETAIL_TRUNC_PART_VAL

- **Purpose:** Generate partition values for data processing

- **Logic:** Format calendar dates as 'YYYY-MM-DD'

### Step 3: Date Partition Management

- **Step Name:** p_SSP_TANK_DETAIL_TRUNC_PART_VAL_DATE

- **Purpose:** Generate date partition values

### Step 4-6: Source Validation Layer

- **Target:** STG_EDW.SSP_TANK_DETAIL_SRCVALID_01

- **Type:** INSERT with APPEND hint

- **Purpose:** Validate and stage source data

- **Materialization:** Table (full refresh)

### Step 7-9: Blend Expression Layer

- **Target:** STG_EDW.SSP_TANK_DETAIL_BLND_EXP_02

- **Type:** INSERT with APPEND hint

- **Purpose:** Apply blend and expression logic

- **Materialization:** Table (full refresh)

### Step 10-12: By Application Layer

- **Target:** STG_EDW.SSP_TANK_DETAIL_BY_APP_03

- **Type:** INSERT with APPEND hint

- **Purpose:** Group/aggregate by application

- **Materialization:** Table (full refresh)

### Step 13-15: By Variety Layer

- **Target:** STG_EDW.SSP_TANK_DETAIL_BY_VRTY_04

- **Type:** INSERT with APPEND hint

- **Purpose:** Group/aggregate by variety

- **Materialization:** Table (full refresh)

### Step 16-18: Final Tank Detail

- **Target:** LND_MANUAL_ENTRY.SSP_TANK_DETAIL

- **Type:** INSERT with complex JOIN

- **Source:** STG_EDW.SSP_TANK_DETAIL_BY_VRTY_04 + STG_EDW.SSP_TANK_DETAIL_BLND_EXP_02

- **Purpose:** Create final consolidated tank detail records

- **Materialization:** Table (incremental/merge pattern)

### Step 19-21: BIMA Processing

- **Target:** LND_MANUAL_ENTRY.SSP_TANK_DETAIL_BIMA

- **Type:** INSERT with data transformation

- **Source:** LND_MANUAL_ENTRY.SSP_TANK_DETAIL

- **Purpose:** Create BIMA-specific tank detail records

### Step 22-24: Calendar Management

- **Target:** LND_MANUAL_ENTRY.SSP_RR_CALENDAR

- **Type:** MERGE operation

- **Purpose:** Maintain calendar reference data

## Oracle Functions Identified

1. **TO_DATE()** - Date conversion

2. **TO_CHAR()** - Character conversion

3. **LPAD()** - Left padding

4. **CASE/WHEN** - Conditional logic

5. **APPEND hint** - Oracle-specific optimization

6. **PARALLEL hint** - Oracle-specific optimization

## dbt Conversion Strategy

### Model Organization

```bash

models/
├── staging/
│   └── pkg_ssp_tank_detail/
│       ├── stg_ssp_rr_calendar.sql
│       └── schema.yml
├── intermediate/
│   └── pkg_ssp_tank_detail/
│       ├── int_tank_detail_source_validation.sql
│       ├── int_tank_detail_blend_expression.sql
│       ├── int_tank_detail_by_application.sql
│       ├── int_tank_detail_by_variety.sql
│       └── schema.yml
├── oracle_packages/
│   └── pkg_ssp_tank_detail/
│       ├── oracle_pkg_tank_detail_pipeline.sql
│       └── schema.yml
└── marts/
    └── tank_detail/
        ├── tank_detail_consolidated.sql
        ├── tank_detail_bima.sql
        └── schema.yml

```bash

### Materialization Strategy

- **Staging:** Views (lightweight transformation)

- **Intermediate:** Tables (complex business logic)

- **Oracle Package:** Tables (maintain Oracle structure)

- **Marts:** Tables with incremental strategy

### Snowflake Optimizations

1. Remove Oracle hints (APPEND, PARALLEL)

2. Replace Oracle date functions with Snowflake equivalents

3. Use automatic clustering instead of manual partitioning

4. Leverage Snowflake's built-in performance optimizations

## Next Steps

1. Create staging models for source tables

2. Build intermediate models following the transformation chain

3. Implement final mart models

4. Add comprehensive testing

5. Document lineage and business logic
