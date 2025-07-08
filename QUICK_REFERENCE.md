# 🚀 QUICK REFERENCE - Oracle to dbt Project

## Project Type: Oracle PL/SQL → dbt + Snowflake Migration

## Setup Checklist

1. Install dbt dependencies: `cd dbt_project && dbt deps`
2. Setup pre-commit hooks: `python scripts/setup_pre_commit.py`
3. Configure profiles: `dbt_project/profiles.yml`

## Key Locations

- **Oracle Packages**: `oracle_packages/source_code/{package_name}/`
- **Oracle Views**: `oracle_packages/views/{domain}/`
- **dbt Models**: `dbt_project/models/`
- **Oracle Macros**: `dbt_project/macros/oracle_utils/`
- **Documentation**: `oracle_packages/mapping/` and `oracle_packages/analysis/`

## Folder Creation Pattern

```bash
# For new Oracle package "PKG_BILLING":
models/staging/pkg_billing/          # Source table cleaning
models/intermediate/pkg_billing/     # Business logic
models/oracle_packages/pkg_billing/  # Direct conversions
models/marts/billing/               # Final reports
```

## Model Naming

- Staging: `stg_{table_name}.sql`
- Intermediate: `int_{purpose}.sql`
- Oracle conversion: `oracle_pkg_{function_name}.sql`
- Marts: `{domain}_{report_name}.sql`

## Oracle Function Conversions

- `NVL(a,b)` → `{{ nvl('a', 'b') }}`
- `DECODE(x,a,b,c)` → `{{ decode('x', 'a', 'b', 'c') }}`
- `MONTHS_BETWEEN(d1,d2)` → `datediff('month', d2, d1)`

## Template Tags

- Staging: `tags=['staging', '{package_name}']`
- Oracle: `tags=['oracle_conversion', '{package_name}']`
- Marts: `tags=['marts', '{business_domain}']`

## Always Include

1. Model documentation in `schema.yml`
2. Oracle source package in model meta
3. Data quality tests
4. Package mapping document

## Business Logic Flow

Oracle Source → Staging (clean) → Oracle Package (convert) → Intermediate (logic) → Marts (final)
