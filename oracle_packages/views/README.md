# Oracle Views

This directory contains Oracle view definitions and logic that are separate from packages.

## Purpose
- Store standalone Oracle views (.sql files)
- Organize view logic that doesn't belong to specific packages
- Maintain view dependencies and documentation

## Structure
```
oracle_packages/views/
├── business_domain_1/
│   ├── view_name_1.sql
│   └── view_name_2.sql
├── business_domain_2/
│   └── view_name_3.sql
└── shared/
    └── common_views.sql
```

## Naming Convention
- **View files**: `{view_name}.sql` (keep original Oracle view name)
- **Folders**: Organize by business domain or functional area
- **Shared views**: Put common/utility views in `shared/` subfolder

## View Documentation
For each view, document:
- Original Oracle view name
- Business purpose and logic
- Source tables and dependencies
- Target dbt model mapping
- Any transformations needed

## Conversion to dbt
Oracle views will typically become:
- **Staging models** if they clean/standardize data
- **Intermediate models** if they contain business logic
- **Mart models** if they're final business outputs

## Example
```sql
-- Original Oracle View: V_CUSTOMER_SUMMARY
CREATE OR REPLACE VIEW V_CUSTOMER_SUMMARY AS
SELECT
    customer_id,
    customer_name,
    total_orders,
    total_spent
FROM customer_base_table;
```

Convert to dbt model: `models/marts/customer/customer_summary.sql`
