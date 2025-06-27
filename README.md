# Data Pipeline Assistant

A comprehensive data pipeline management and automation tool designed for converting Oracle PL/SQL packages to dbt models.

## Project Overview

This repository contains a structured dbt project optimized for:
- Converting Oracle database packages to dbt models
- Maintaining clear lineage from Oracle source to dbt transformations
- Supporting coding assistants with well-organized folder structures
- Enabling collaboration between database developers and analytics engineers

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
4. **Run conversion**: Follow patterns in `QUICK_REFERENCE.md`

## Project Structure

```
├── dbt_project/                 # Main dbt project
│   ├── models/
│   │   ├── staging/            # Source data cleaning
│   │   ├── intermediate/       # Business logic
│   │   ├── marts/             # Final reports (finance, sales, operations)
│   │   └── oracle_packages/   # Direct Oracle conversions
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

## Usage

1. Place Oracle packages in `oracle_packages/source_code/`
2. Follow naming conventions in `QUICK_REFERENCE.md`
3. Use the layered approach: staging → intermediate → marts
4. Reference `AI_ASSISTANT_GUIDE.md` for detailed conversion patterns

## Key Features

### Rich Metadata
- Comprehensive `schema.yml` files with column descriptions
- Meta tags linking dbt models to original Oracle packages
- Conversion tracking with dates and responsible teams

### Documentation-Driven Development
- README files in each major directory
- Conversion mapping documentation

