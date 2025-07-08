# Oracle Packages Documentation

This directory contains the Oracle packages that need to be converted to dbt models.

## Directory Structure

```yaml
oracle_packages/
├── source_code/          # Original Oracle package files (.sql, .pks, .pkb)
├── views/               # Oracle view definitions (separate from packages)
├── documentation/        # Package documentation and specifications
├── mapping/             # Mapping files between Oracle and dbt models
└── analysis/           # Analysis reports and conversion notes
```

## Adding Oracle Packages and Views

1. **Packages**: Place your Oracle package files (`.sql`, `.pks`, `.pkb`) in the `source_code/` directory
2. **Views**: Place Oracle view definitions in the `views/` directory
3. Organize by business domain or functionality
4. Add corresponding documentation in the `documentation/` directory
5. Create mapping files in the `mapping/` directory to track conversions

## Naming Conventions

- Source files: Keep original Oracle naming conventions
- Documentation: `{package_name}_documentation.md`
- Mapping files: `{package_name}_mapping.yml`
- Analysis: `{package_name}_analysis.md`

## Conversion Process

1. **Analysis**: Understand the Oracle package functionality
2. **Mapping**: Create mapping between Oracle procedures/functions and dbt models
3. **Implementation**: Create dbt models in the appropriate layer (staging/intermediate/marts)
4. **Testing**: Add data tests to ensure accuracy
5. **Documentation**: Document the converted models

## Example Structure

```
source_code/
├── finance/
│   ├── PKG_FINANCIAL_REPORTS.sql
│   ├── PKG_GL_PROCESSING.sql
│   └── PKG_BUDGET_CALCULATIONS.sql
├── sales/
│   ├── PKG_SALES_ANALYTICS.sql
│   └── PKG_COMMISSION_CALC.sql
└── operations/
    ├── PKG_INVENTORY_MGMT.sql
    └── PKG_SUPPLY_CHAIN.sql

views/
├── finance/
│   ├── V_FINANCIAL_SUMMARY.sql
│   └── V_BUDGET_REPORT.sql
├── sales/
│   └── V_SALES_DASHBOARD.sql
└── shared/
    └── V_COMMON_LOOKUPS.sql
```
