# Data Pipeline Assistant

A comprehensive data pipeline management and automation tool designed for converting Oracle PL/SQL packages to dbt models
with built-in quality assurance through pre-commit hooks.

## Project Overview

This repository contains a structured dbt project optimized for:

- Converting Oracle database packages to dbt models
- Maintaining clear lineage from Oracle source to dbt transformations
- Supporting coding assistants with well-organized folder structures
- Enabling collaboration between database developers and analytics engineers
- **Automated code quality checks with pre-commit hooks**

## Features

### 🔧 **Code Quality & Formatting**

- **Python**: Black formatting, isort imports, Flake8 linting
- **SQL**: SQLFluff linting and formatting optimized for dbt + Snowflake
- **YAML**: Validation for dbt configuration files
- **Markdown**: Consistent documentation formatting
- **General**: Trailing whitespace, line endings, merge conflicts

### 🎯 **dbt-Specific Validations**

- Model naming conventions enforcement
- Required documentation checks (models, columns, sources)
- Dependency management ({{ ref() }}, {{ source() }})

### 🏛️ **Oracle Migration Specific**

- Oracle package structure validation
- Conversion documentation requirements
- Oracle function → dbt macro coverage analysis
- Migration progress tracking

## Quick Start

1. **Add Oracle packages** to `oracle_packages/source_code/`
2. **Configure connection** - Choose one:
   - **Option A (File)**: Copy `dbt_project/.env.example` to `.env` and fill in credentials
   - **Option B (CLI)**: Set environment variables in PowerShell:

     ```powershell
     $env:SNOWFLAKE_ACCOUNT = "your_account.region"
     $env:SNOWFLAKE_USER = "your_username"
     $env:SNOWFLAKE_PASSWORD = "your_password"
     ```

3. **Install dependencies**: `cd dbt_project && dbt deps`
4. **Setup pre-commit hooks**: `python scripts/setup_pre_commit.py`
5. **Run conversion**: Follow patterns in `QUICK_REFERENCE.md`

## Project Structure

```
├── dbt_project/                 # Main dbt project
│   ├── models/
│   │   ├── staging/            # Source definitions and examples
│   │   └── {project_name}/     # Create folders per project/task
│   └── macros/oracle_utils/   # Oracle function replacements
├── oracle_packages/           # Oracle source management
│   ├── source_code/          # Put .sql, .pks, .pkb files here
│   └── analysis/             # Conversion tracking
└── scripts/                  # Conversion utilities
```

## Oracle Function Conversions

Available macros for Oracle compatibility:

- `{{ nvl('column', 'default') }}` - Replaces NVL with COALESCE
- `{{ decode('col', 'val1', 'result1', 'default') }}` - Replaces DECODE with CASE statements
- `{{ oracle_to_date('date_string', 'format') }}` - Replaces TO_DATE

## Usage

1. Place Oracle packages in `oracle_packages/source_code/`
2. Follow naming conventions in `QUICK_REFERENCE.md`
3. Use the layered approach: staging → intermediate → marts
4. Reference `AI_ASSISTANT_GUIDE.md` for detailed conversion patterns
5. See `models/staging/_sources_example.yml` for source definition examples

## Key Features

### Rich Metadata

- Comprehensive `schema.yml` files with column descriptions
- Meta tags linking dbt models to original Oracle packages
- Conversion tracking with dates and responsible teams

### Documentation-Driven Development

- README files in each major directory
- Conversion mapping documentation

## Code Quality & Pre-commit Hooks

This project includes comprehensive pre-commit hooks to ensure code quality:

- **SQL Linting**: SQLFluff with dbt/Snowflake optimization
- **Python Formatting**: Black, isort, Flake8
- **dbt Validation**: Model naming, documentation, test coverage
- **Oracle Migration**: Package structure and macro coverage validation

**Setup**: Run `python scripts/setup_pre_commit.py`
**Documentation**: See [Pre-commit Feature Guide](docs/PRE_COMMIT_FEATURE.md)

This project provides a robust framework for migrating Oracle databases to Snowflake using dbt,
with a strong emphasis on automation, code quality, and AI-driven development.

```text
- `{{ nvl('column', 'default') }}` → `nvl(column, 'default')`
- `{{ decode(...) }}` → `case ... end`
```
