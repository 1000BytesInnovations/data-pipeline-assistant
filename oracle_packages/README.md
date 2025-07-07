# Oracle Packages Repository

This directory contains Oracle database packages that are being migrated to dbt models for Snowflake.

## Structure

```bash

oracle_packages/
├── analysis/                    # Package analysis and conversion documentation
│   ├── PKG_SSP_TANK_DETAIL_analysis.md
│   └── PKG_SSP_TANK_DETAIL_conversion_summary.md
├── source_code/                # Original Oracle package source files
├── views/                      # Oracle view definitions (if applicable)
└── README.md                   # This file

```bash

## Purpose

Each Oracle package undergoes a systematic conversion process:

1. **Analysis**: Detailed analysis of the Oracle package structure, dependencies, and business logic

2. **Documentation**: Comprehensive mapping of Oracle constructs to dbt equivalents

3. **Conversion**: Implementation of dbt models following the layered architecture

4. **Testing**: Validation of converted logic against Oracle source

## Conversion Standards

- **Staging Layer**: Direct source table mappings with minimal transformations

- **Intermediate Layer**: Business logic decomposition and modular transformations

- **Marts Layer**: Final business-ready models optimized for analytics

- **Oracle Packages Layer**: Direct Oracle-to-dbt conversions for comparison

## Package Status

### ✅ PKG_SSP_TANK_DETAIL (Completed)

- **Analysis**: Complete 25-step Oracle procedure decomposed

- **Models**: 8 dbt models created across all layers

- **Testing**: 50+ data quality tests implemented

- **Documentation**: Full schema.yml files with business descriptions

## Migration Guidelines

For each new Oracle package:

1. Place original Oracle source files in `source_code/`

2. Create detailed analysis in `analysis/[PACKAGE_NAME]_analysis.md`

3. Document conversion decisions in `analysis/[PACKAGE_NAME]_conversion_summary.md`

4. Implement dbt models following the established patterns

5. Create comprehensive tests and documentation

## Quality Standards

All conversions must include:

- Complete business logic documentation

- Data quality tests at each layer

- Performance optimization for Snowflake

- Incremental processing where applicable

- Error handling and data validation

## Support

For questions about Oracle package conversions, refer to:

- `AI_ASSISTANT_GUIDE.md` - Detailed conversion patterns and templates

- `docs/PRE_COMMIT_FEATURE.md` - Code quality standards

- Individual package analysis files for specific implementation details
