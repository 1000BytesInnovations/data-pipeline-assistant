# 🤖 AI Assistant Guide for Oracle to dbt Migration

## Project Purpose

Convert Oracle PL/SQL packages and ODI logic to dbt models running on Snowflake.

## Key Instructions for AI Assistants

### File Locations

- **Oracle source files**: Place in `oracle_packages/source_code/{package_name}/`

- **dbt models**: Create in `dbt_project/models/` following the layered approach

- **Oracle utility macros**: Available in `dbt_project/macros/oracle_utils/`

### Model Organization Pattern

```bash

dbt_project/models/
├── staging/                     # Source data cleaning and standardization
│   └── {package_name}/         # Package-specific staging models
├── intermediate/               # Business logic and calculations
│   └── {package_name}/         # Package-specific intermediate models
├── oracle_packages/            # Direct Oracle package conversions
│   └── {package_name}/         # Complete pipeline conversions
└── marts/                      # Final business-ready models
    └── {domain}/               # Domain-specific mart models

```bash

### Naming Conventions

- **Staging**: `stg_{table_name}.sql` (e.g., `stg_ssp_rr_calendar.sql`)

- **Intermediate**: `int_{purpose}.sql` (e.g., `int_tank_detail_by_variety.sql`)

- **Oracle conversions**: `oracle_pkg_{package_name}.sql` (e.g., `oracle_pkg_tank_detail_pipeline.sql`)

- **Marts**: `{domain}_{purpose}.sql` (e.g., `tank_detail_consolidated.sql`)

### Conversion Workflow

1. **Analyze** Oracle package structure and dependencies

2. **Create** appropriate folder structure following the pattern above

3. **Convert** using available Oracle utility macros

4. **Add** proper documentation and tests

5. **Test** models in development environment only

### Materialization Strategy

- **Staging models**: Use `materialized='view'` for lightweight transformations

- **Intermediate models**: Use `materialized='table'` for complex calculations

- **Oracle package models**: Use `materialized='incremental'` with merge strategy for large datasets

- **Mart models**: Use `materialized='incremental'` or `materialized='table'` based on size and usage

### Oracle-to-Snowflake Conversion Guidelines

- **Partitioning**: Remove Oracle partition maintenance logic (Snowflake handles automatically)

- **Index hints**: Remove Oracle-specific index hints

- **Procedures**: Convert procedural logic to CTEs and dbt macros

- **Merge operations**: Use dbt incremental with merge strategy

- **Temporary tables**: Replace with CTEs where possible

## 🔧 Oracle Function Conversion Guide

### **Common Oracle → Snowflake Patterns**

```sql

-- Oracle NVL

NVL(column, 'default') → {{ nvl('column', "'default'") }}

-- Oracle DECODE

DECODE(status, 'A', 'Active', 'I', 'Inactive') → {{ decode('status', "'A'", "'Active'", "'I'", "'Inactive'") }}

-- Oracle DATE_DIFF

DATE_DIFF(interval, date1, date2) → DATEDIFF(interval, date1, date2)

-- Oracle MONTHS_BETWEEN

MONTHS_BETWEEN(date1, date2) → datediff('month', date2, date1)

-- Oracle ADD_MONTHS

ADD_MONTHS(date_col, 6) → dateadd('month', 6, date_col)

-- Oracle TRUNC

TRUNC(date_col, 'MONTH') → date_trunc('month', date_col)

```bash

### **Available Macros**

- `{{ nvl('column', 'default') }}` - Replaces Oracle NVL with COALESCE

- `{{ decode('col', 'val1', 'result1', 'default') }}` - Replaces Oracle DECODE with CASE statements

## 📋 Template Usage

### **Staging Model Template**

```sql

{{ config(
    materialized='view',
    tags=['staging', '{package_name}']
) }}

/*
  Staging model for {source_table}

  Cleans and standardizes raw data from the source system.

  Source: {schema}.{table_name}
  Purpose: Data cleaning and standardization
*/

with source_data as (
    select * from {{ source('raw_data', '{table_name}') }}

),

cleaned_data as (
    select
        -- Clean and standardize columns

        trim(upper(column1)) as column1,
        cast(column2 as decimal(15,2)) as column2,
        current_timestamp() as dbt_loaded_at
    from source_data
    where column1 is not null
)

select * from cleaned_data

```bash

### **Oracle Package Model Template**

```sql

{{ config(
    materialized='incremental',
    unique_key='primary_key_column',
    incremental_strategy='merge',
    tags=['oracle_conversion', '{package_name}'],
    meta={
        'oracle_source_package': '{PACKAGE_NAME}',
        'oracle_step': '{STEP_DESCRIPTION}',
        'layer': 'oracle_packages',
        'business_domain': '{domain_name}'
    }
) }}

/*
  Oracle Package Conversion: {PACKAGE_NAME}

  This model recreates the Oracle package logic in dbt format.

  Oracle Package: {PACKAGE_NAME}
  Oracle Steps: {step_numbers}

  Purpose: {business_purpose}
*/

-- Step descriptions and CTEs

with source_data as (
    select * from {{ ref('stg_{source_table}') }}

),

-- Business logic CTEs

business_logic as (
    select
        -- Convert Oracle calculations to Snowflake SQL

        column1,
        column2,
        -- Use Oracle compatibility macros where needed

        {{ nvl('column3', "'DEFAULT'") }} as column3_clean,
        {{ decode('status', "'A'", "'Active'", "'I'", "'Inactive'", "'Unknown'") }} as status_desc
    from source_data
),

final as (
    select
        *,
        current_timestamp() as _dbt_loaded_at,
        '{{ run_started_at }}' as _dbt_run_started_at
    from business_logic
    {% if is_incremental() %}
        -- For incremental runs, only process new/changed data

        where update_timestamp > (select coalesce(max(update_timestamp), '1900-01-01'::timestamp) from {{ this }})
    {% endif %}
)

select * from final

```bash

### **Intermediate Model Template**

```sql

{{ config(
    materialized='table',
    tags=['intermediate', '{package_name}'],
    meta={
        'layer': 'intermediate',
        'business_domain': '{domain_name}'
    }
) }}

/*
  Intermediate model: {purpose}

  Performs complex business logic calculations.

  Depends on: {upstream_models}
  Used by: {downstream_models}
*/

with upstream_data as (
    select * from {{ ref('{upstream_model}') }}

),

calculations as (
    select
        -- Complex business logic here

        *
    from upstream_data

)

select * from calculations

```bash

## 🧪 Testing Requirements

### **Always Add These Tests**

1. **Data quality tests** in `schema.yml` files

2. **Source freshness** for staging models

3. **Business logic validation** for conversions

4. **Reconciliation tests** comparing Oracle vs dbt outputs (development only)

### **Test Template**

```yaml

version: 2

models:
  - name: oracle_pkg_{function_name}

    description: "Converted from Oracle {PACKAGE_NAME}.{PROCEDURE_NAME}"
    columns:
      - name: {key_column}

        tests:
          - unique

          - not_null

      - name: {business_column}

        tests:
          - not_null

          - accepted_values:

              values: ['value1', 'value2', 'value3']
    tests:
      - dbt_utils.equal_rowcount:

          compare_model: ref('{comparison_model}')

```bash

## 📖 Documentation Requirements

### **Always Document**

1. **Oracle source package** name and purpose

2. **Business logic** being replicated

3. **Data lineage** from source to target

4. **Conversion notes** and any changes made

### **Documentation Template**

```yaml

version: 2

sources:
  - name: raw_data

    description: "Raw data from source systems"
    tables:
      - name: {table_name}

        description: "Source table description"
        columns:
          - name: {column_name}

            description: "Column description"

models:
  - name: {model_name}

    description: |
      Converted from Oracle package {PACKAGE_NAME}.

      **Business Purpose**: {purpose}
      **Original Logic**: {oracle_logic_summary}
      **Conversion Notes**: {any_changes_made}
    columns:
      - name: {column_name}

        description: "{column_description}"

```bash

## 🎯 AI Assistant Commands

### **When Asked to Convert Oracle Package**

1. First ask: "What's the Oracle package name and what business area does it handle?"

2. Create folder structure based on package name following the pattern above

3. Analyze Oracle logic and create appropriate models in order: staging → intermediate → oracle_packages → marts

4. Add tests and documentation

5. Use Oracle compatibility macros where needed

### **File Organization Priority**

1. **Packages**: Keep Oracle source files in `oracle_packages/source_code/{package_name}/`

2. Create dbt models following the layered approach

3. Create mapping document in `oracle_packages/mapping/{package_name}_mapping.md`

4. Build comprehensive tests in `schema.yml` files

5. Maintain clear separation between development and production environments

### **Model Creation Order**

1. **Staging models** (`stg_*`) - Clean source tables

2. **Intermediate models** (`int_*`) - Business logic components

3. **Oracle package models** (`oracle_pkg_*`) - Complete pipeline conversions

4. **Mart models** (`{domain}_*`) - Final business outputs

### **Always Include**

- Proper `{{ config() }}` blocks with appropriate materialization

- Tags for organization: `['staging', 'package_name']`, `['oracle_conversion', 'package_name']`, etc.

- Meta information linking to original Oracle packages

- Comprehensive tests in `schema.yml`

- Documentation describing the conversion

## ⚠️ Important Notes

### **Development vs Production**

- **Development**: Use test data and simplified schemas for development and testing

- **Production**: Ensure proper source connections and data validation

- **Never**: Include test data creation scripts in production deployments

### **Error Handling**

- Replace Oracle exception handling with dbt tests

- Use dbt macros for reusable logic

- Implement data quality checks at each layer

### **Performance Optimization**

- Use incremental materialization for large datasets

- Implement proper unique keys for merge operations

- Consider clustering and warehousing strategies for Snowflake

## 🔍 Common Conversion Patterns

### **Oracle Cursors → CTEs**

```sql

-- Oracle cursor pattern

FOR record IN cursor_name LOOP
  -- processing logic

END LOOP;

-- dbt CTE pattern

with cursor_data as (
  select * from source_table

),
processed_data as (
  select
    -- processing logic here

  from cursor_data
)

```bash

### **Oracle Procedures → dbt Models**

```sql

-- Oracle procedure pattern

PROCEDURE process_data IS
BEGIN
  INSERT INTO target_table
  SELECT * FROM source_table WHERE condition;

END;

-- dbt model pattern

{{ config(materialized='incremental') }}

select * from {{ ref('source_model') }}

where condition
{% if is_incremental() %}
  and update_date > (select max(update_date) from {{ this }})
{% endif %}

```bash

### **Oracle Merge → dbt Incremental**

```sql

-- Oracle MERGE pattern

MERGE INTO target t
USING source s ON (t.id = s.id)
WHEN MATCHED THEN UPDATE SET t.value = s.value
WHEN NOT MATCHED THEN INSERT VALUES (s.id, s.value);

-- dbt incremental with merge strategy

{{ config(
    materialized='incremental',
    unique_key='id',
    incremental_strategy='merge'
) }}

select id, value from {{ ref('source_model') }}
{% if is_incremental() %}
  where update_date > (select max(update_date) from {{ this }})
{% endif %}

```bash
