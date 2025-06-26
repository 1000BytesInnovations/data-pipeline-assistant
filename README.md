# Data Pipeline Assistant

A comprehensive data pipeline management and automation tool designed for converting Oracle PL/SQL packages to dbt models.

## Project Overview

This repository contains a structured dbt project optimized for:
- Converting Oracle database packages to dbt models
- Maintaining clear lineage from Oracle source to dbt transformations
- Supporting coding assistants with well-organized folder structures
- Enabling collaboration between database developers and analytics engineers

## Repository Structure

```
├── dbt_project/                 # Main dbt project
│   ├── models/
│   │   ├── staging/            # Base staging models
│   │   ├── intermediate/       # Business logic models
│   │   ├── marts/             # Final business models
│   │   │   ├── finance/       # Finance domain models
│   │   │   ├── sales/         # Sales domain models
│   │   │   └── operations/    # Operations domain models
│   │   └── oracle_packages/   # Direct Oracle package conversions
│   ├── macros/
│   │   └── oracle_utils/      # Oracle function conversion macros
│   ├── tests/                 # Data quality tests
│   ├── seeds/                 # Reference data
│   ├── snapshots/             # SCD Type 2 tracking
│   └── analysis/              # Ad-hoc analysis queries
├── docs/
│   └── oracle_packages/       # Oracle conversion documentation
└── scripts/                   # Utility scripts for conversion
```

## Quick Start

### 1. Environment Setup
```bash
cd dbt_project
cp .env.example .env
# Edit .env with your Oracle connection details
```

### 2. Install dbt Dependencies
```bash
dbt deps
```

### 3. Test Connection
```bash
dbt debug
```

### 4. Run Models
```bash
dbt run
dbt test
```

## Oracle Package Conversion

### Analysis Tools
Use the provided scripts to analyze your Oracle packages:

**Windows:**
```batch
scripts\oracle_conversion_helper.bat
```

**Linux/Mac:**
```bash
scripts/analyze_oracle_packages.sh
```

### Conversion Process
1. **Analyze**: Run analysis scripts to understand package structure
2. **Document**: Update `docs/oracle_packages/conversion_mapping.md`
3. **Convert**: Create dbt models in `models/oracle_packages/`
4. **Test**: Validate against original Oracle output
5. **Document**: Add comprehensive documentation

### Oracle Function Macros
The project includes macros to convert Oracle-specific functions:
- `oracle_months_between()` - Replaces MONTHS_BETWEEN
- `oracle_add_months()` - Replaces ADD_MONTHS
- `oracle_nvl()` - Replaces NVL
- `oracle_decode()` - Replaces DECODE
- `oracle_to_char()` - Replaces TO_CHAR

## Coding Assistant Optimization

This structure is designed to work optimally with coding assistants:

### Clear Naming Conventions
- `stg_` prefix for staging models
- `int_` prefix for intermediate models  
- `mart_` prefix for mart models
- `oracle_pkg_` prefix for Oracle package conversions

### Rich Metadata
- Comprehensive `schema.yml` files with column descriptions
- Meta tags linking dbt models to original Oracle packages
- Conversion tracking with dates and responsible teams

### Documentation-Driven Development
- README files in each major directory
- Conversion mapping documentation
- Business logic preservation notes

## Development Workflow

### Feature Branch Process
1. Create feature branch from `develop`
2. Make changes to dbt models/documentation
3. Test locally with `dbt run` and `dbt test`
4. Commit changes with descriptive messages
5. Push to remote feature branch
6. Open Pull Request to `develop`

### Recommended Commit Message Format
```
type(scope): description

Examples:
feat(oracle): convert PKG_FINANCE_CALC to dbt model
docs(conversion): update mapping for sales packages
fix(macro): correct oracle_months_between calculation
test(finance): add validation for customer scoring model
```

## Branches

- `main`: Production-ready code
- `develop`: Development branch (default)
- `feature/*`: Feature development branches

## Getting Started

### Prerequisites
- dbt-core >= 1.0.0
- Oracle database access
- Python >= 3.8

### Installation
1. Clone the repository
2. Navigate to `dbt_project/` directory
3. Copy `.env.example` to `.env` and configure Oracle connection
4. Install dbt dependencies: `dbt deps`
5. Test connection: `dbt debug`

### First Conversion
1. Run Oracle analysis script to understand package structure
2. Use the model template in `scripts/` to create your first conversion
3. Follow the conversion guidelines in `docs/oracle_packages/README.md`

## Contributing

Please create feature branches from `develop` and submit pull requests back to `develop`.

### Contribution Guidelines
1. Follow dbt best practices for model organization
2. Include comprehensive documentation for Oracle conversions
3. Add appropriate tests for converted models
4. Update conversion mapping documentation
5. Preserve original Oracle business logic unless specifically changing it

## Support

For questions about Oracle package conversion or dbt best practices, please:
1. Check the documentation in `docs/oracle_packages/`
2. Review existing conversion examples in `models/oracle_packages/`
3. Consult the Oracle utility macros in `macros/oracle_utils/`
