# Oracle Source Code

Place your Oracle package files (.sql, .pks, .pkb) in this directory, organized by business domain.

## Structure

```yaml
source_code/
├── finance/          # Financial packages
├── sales/            # Sales and marketing packages
├── operations/       # Operations and logistics packages
└── {domain}/         # Add more domains as needed
```

## File Types

- **`.sql`** - Complete Oracle package (spec + body)
- **`.pks`** - Package specification only
- **`.pkb`** - Package body only

## Naming Convention

Keep original Oracle naming:

- `PKG_FINANCIAL_REPORTS.sql`
- `PKG_SALES_ANALYTICS.pks` + `PKG_SALES_ANALYTICS.pkb`
- `PKG_COMMISSION_CALC.sql`

## Usage

1. **Copy Oracle files** into appropriate domain folder
2. **Run analysis** using scripts in `/scripts` folder
3. **Create dbt models** following patterns in AI_ASSISTANT_GUIDE.md
4. **Document conversion** in `/oracle_packages/analysis`

## Example

```
finance/
├── PKG_FINANCIAL_REPORTS.sql      # Complete package
├── PKG_GL_PROCESSING.pks          # Package spec
├── PKG_GL_PROCESSING.pkb          # Package body
└── PKG_BUDGET_CALCULATIONS.sql    # Complete package
```
