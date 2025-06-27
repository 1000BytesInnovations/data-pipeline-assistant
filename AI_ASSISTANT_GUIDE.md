# 🤖 AI Coding Assistant Guide for Oracle to dbt Migration

## Project Overview
This is an Oracle PL/SQL package to dbt models migration project using Snowflake as the target database. The structure is designed for systematic conversion of Oracle packages to modern dbt workflows.

## 📁 Project Structure & AI Instructions

### **Oracle Package Location**
- **Packages**: All Oracle packages (.sql, .pks, .pkb, .html) go in `oracle_packages/source_code/`
- **Views**: Oracle view definitions go in `oracle_packages/views/`
- **Organization**: Create subdirectories by package name or business domain

### **dbt Models Organization**
When converting Oracle packages, follow this pattern:

```
dbt_project/models/
├── staging/
│   └── {package_name}/           # Clean source tables for this package
├── intermediate/  
│   └── {package_name}/           # Complex business logic for this package
├── marts/
│   └── {business_domain}/        # Final outputs organized by business area
└── oracle_packages/
    └── {package_name}/           # Direct package conversions
```

### **Naming Conventions**
- **Staging models**: `stg_{table_name}.sql`
- **Intermediate models**: `int_{purpose}.sql`
- **Mart models**: `{business_area}_{report_name}.sql`
- **Oracle package models**: `oracle_pkg_{function_name}.sql`

## 🎯 AI Assistant Workflow

### **Step 1: Analyze Oracle Components**
When given Oracle packages or views:
1. **Packages**: Identify package name, procedures, and functions
2. **Views**: Identify view purpose and source tables
3. Map source tables and business logic
4. Determine target business domain (finance, sales, operations, etc.)

### **Step 2: Create Folder Structure**
```bash
# Create package-specific folders
mkdir dbt_project/models/staging/{package_name}
mkdir dbt_project/models/intermediate/{package_name}  
mkdir dbt_project/models/oracle_packages/{package_name}
mkdir dbt_project/models/marts/{business_domain}
```

### **Step 3: Create Models in Order**
1. **Staging models** - Clean source tables
2. **Oracle package models** - Direct conversions 
3. **Intermediate models** - Complex calculations
4. **Mart models** - Final business outputs

### **Step 4: Use Oracle Compatibility**
- Use macros from `macros/oracle_utils/` for Oracle functions
- Available macros: `nvl()`, `decode()`, `oracle_months_between()`, etc.

## 🔧 Oracle Function Conversion Guide

### **Common Oracle → Snowflake Patterns**
```sql
-- Oracle NVL
NVL(column, 'default') → {{ nvl('column', "'default'") }}

-- Oracle DECODE  
DECODE(status, 'A', 'Active', 'I', 'Inactive') → {{ decode('status', "'A'", "'Active'", "'I'", "'Inactive'") }}

-- Oracle MONTHS_BETWEEN
MONTHS_BETWEEN(date1, date2) → datediff('month', date2, date1)

-- Oracle ADD_MONTHS
ADD_MONTHS(date_col, 6) → dateadd('month', 6, date_col)
```

## 📋 Template Usage

### **Staging Model Template**
```sql
{{ config(materialized='view', tags=['staging', '{package_name}']) }}

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
```

### **Oracle Package Model Template**
```sql
{{ config(
    materialized='view',
    tags=['oracle_conversion', '{package_name}'],
    meta={
        'oracle_package': '{PACKAGE_NAME}',
        'original_procedure': '{PROCEDURE_NAME}',
        'conversion_notes': 'Brief description of conversion'
    }
) }}

-- Original Oracle package: {PACKAGE_NAME}.{PROCEDURE_NAME}
-- Business logic: {description}

with {logical_name} as (
    select * from {{ ref('stg_{source_table}') }}
),

-- Replicate Oracle business logic
{calculation_name} as (
    select
        -- Convert Oracle calculations to SQL
    from {logical_name}
)

select * from {calculation_name}
```

## 🧪 Testing Requirements

### **Always Add These Tests**
1. **Data quality tests** in `schema.yml` files
2. **Source freshness** for staging models  
3. **Business logic validation** for conversions
4. **Reconciliation tests** comparing Oracle vs dbt outputs

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
    tests:
      - dbt_expectations.expect_table_row_count_to_be_between:
          min_value: 1000
          max_value: 1000000
```

## 📖 Documentation Requirements

### **Always Document**
1. **Oracle source package** name and purpose
2. **Business logic** being replicated
3. **Data lineage** from source to target
4. **Conversion notes** and any changes made

## 🎯 AI Assistant Commands

### **When Asked to Convert Oracle Package**
1. First ask: "What's the Oracle package name and what business area does it handle?"
2. Create folder structure based on package name
3. Analyze Oracle logic and create appropriate models
4. Add tests and documentation
5. Use Oracle compatibility macros where needed

### **File Organization Priority**
1. **Packages**: Keep Oracle source files in `oracle_packages/source_code/{package_name}/`
2. **Views**: Keep Oracle views in `oracle_packages/views/{domain}/`
3. Create mapping document in `oracle_packages/mapping/{component_name}_mapping.md`
4. Build dbt models following the layered approach
5. Maintain clear separation between packages and views

## 🚀 Success Criteria

A successful conversion includes:
- ✅ All Oracle business logic preserved
- ✅ Clear folder organization by package
- ✅ Appropriate tests and documentation  
- ✅ Oracle functions converted using macros
- ✅ Models follow dbt best practices
- ✅ Code is readable and maintainable

---

**This guide ensures any AI assistant can understand the project structure and follow consistent patterns for Oracle package conversion.**
