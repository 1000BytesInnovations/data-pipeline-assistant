# Oracle to dbt Package Conversion Guide

## Overview
This project contains dbt models converted from Oracle PL/SQL packages. The structure is designed to maintain clarity about the original Oracle source while following dbt best practices.

## Folder Structure

### `/models`
- **`/staging`**: Base staging models that clean and standardize source data
- **`/intermediate`**: Business logic models that combine staging models
- **`/marts`**: Final business-ready models organized by domain (finance, sales, operations)
- **`/oracle_packages`**: Direct conversions from Oracle packages with preserved business logic

### `/macros`
- **`/oracle_utils`**: Macros that replicate Oracle-specific functions (MONTHS_BETWEEN, ADD_MONTHS, NVL, DECODE, etc.)

### `/docs`
- **`/oracle_packages`**: Documentation mapping Oracle packages to dbt models

## Oracle Package Conversion Guidelines

### 1. Naming Convention
- Original Oracle package: `PKG_FINANCE_CALC`
- Converted dbt model: `oracle_pkg_finance_calculations.sql`
- Follow pattern: `oracle_pkg_{domain}_{function}.sql`

### 2. Model Configuration
Each converted Oracle package model should include:
```yaml
{{ config(
    materialized='view',
    tags=['oracle_conversion', 'domain_name'],
    meta={
        'oracle_package': 'ORIGINAL_PACKAGE_NAME',
        'original_procedure': 'ORIGINAL_PROCEDURE_NAME',
        'conversion_notes': 'Description of conversion'
    }
) }}
```

### 3. Documentation Requirements
- Include original Oracle package name in model documentation
- Document conversion date and who performed the conversion
- Explain any logic changes made during conversion
- Add comments explaining Oracle-specific business rules

### 4. Testing Strategy
- Test converted models against Oracle package outputs for data validation
- Include both generic dbt tests and custom tests
- Create reconciliation models to compare Oracle vs dbt results

## Oracle Function Conversions

### Available Macros
- `{{ oracle_months_between(date1, date2) }}` - Replaces `MONTHS_BETWEEN`
- `{{ oracle_add_months(date_col, months) }}` - Replaces `ADD_MONTHS`  
- `{{ oracle_nvl(expr1, expr2) }}` - Replaces `NVL`
- `{{ oracle_decode(expression, search1, result1) }}` - Replaces `DECODE`
- `{{ oracle_to_char(date_expr, format) }}` - Replaces `TO_CHAR`

### Usage Example
```sql
-- Oracle original
SELECT MONTHS_BETWEEN(end_date, start_date) as months_diff
FROM table_name;

-- dbt conversion
SELECT {{ oracle_months_between('end_date', 'start_date') }} as months_diff
FROM {{ ref('table_name') }};
```

## Development Workflow

### 1. Package Analysis
Before converting an Oracle package:
1. Document the package purpose and business logic
2. Identify all procedures and functions
3. Map data dependencies and table relationships
4. Note any Oracle-specific functions used

### 2. Conversion Process
1. Create staging models for source tables
2. Convert each procedure/function to a separate dbt model
3. Use Oracle utility macros for database-specific functions
4. Preserve original business logic and calculations
5. Add comprehensive documentation and metadata

### 3. Validation
1. Run converted models alongside original Oracle packages
2. Compare outputs for accuracy
3. Create data quality tests
4. Document any differences or limitations

## Model Dependencies

```
Oracle Source Tables
    ↓
Staging Models (stg_*)
    ↓
Oracle Package Models (oracle_pkg_*)
    ↓
Intermediate Models (int_*)
    ↓
Mart Models (mart_*)
```

## Testing and Validation

### Reconciliation Models
Create reconciliation models to validate Oracle package conversions:
```sql
-- reconcile_finance_calculations.sql
with oracle_results as (
    select * from oracle_legacy.finance_calc_results
),
dbt_results as (
    select * from {{ ref('oracle_pkg_finance_calculations') }}
)
select 
    coalesce(o.customer_id, d.customer_id) as customer_id,
    o.calculation_result as oracle_result,
    d.calculation_result as dbt_result,
    abs(o.calculation_result - d.calculation_result) as difference
from oracle_results o
full outer join dbt_results d on o.customer_id = d.customer_id
where abs(o.calculation_result - d.calculation_result) > 0.01
```

## Best Practices

1. **Preserve Business Logic**: Keep original Oracle calculations intact
2. **Document Everything**: Include extensive comments about Oracle source
3. **Use Metadata**: Tag models with Oracle package information
4. **Test Thoroughly**: Validate outputs against original Oracle packages
5. **Version Control**: Track which Oracle package version was converted
6. **Incremental Approach**: Convert packages one at a time
7. **Collaborate**: Work with business users to validate converted logic
