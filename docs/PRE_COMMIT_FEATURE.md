# Pre-commit Hooks Feature

This document describes the pre-commit hooks feature added to the Data Pipeline Assistant for Oracle to dbt migrations.

## Overview

Pre-commit hooks ensure code quality, consistency, and best practices across the entire project. They automatically run checks
and fixes before code is committed to the repository.

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

- Test coverage validation for critical models

- Macro documentation requirements

- Project compilation validation

- Dependency management ({{ ref() }}, {{ source() }})

### 🏛️ **Oracle Migration Specific**

- Oracle package structure validation

- Conversion documentation requirements

- Oracle function → dbt macro coverage analysis

- Migration progress tracking

## Quick Start

### 1. Setup Pre-commit Hooks

```bash

# Run the setup script

python scripts/setup_pre_commit.py

# Or manually

pip install pre-commit
pre-commit install
pre-commit install --hook-type commit-msg

```bash

### 2. Test the Setup

```bash

# Run on all files (first run downloads dependencies)

pre-commit run --all-files

# Run specific hook

pre-commit run sqlfluff-lint

```bash

### 3. Normal Usage

Pre-commit hooks now run automatically on every `git commit`. If hooks fail:

1. Review the output - many issues are auto-fixed

2. Add the fixes: `git add .`

3. Commit again: `git commit -m "Your message"`

## Configuration Files

| File | Purpose |
|------|---------|
| `.pre-commit-config.yaml` | Main pre-commit configuration |
| `.sqlfluff` | SQL linting rules for dbt/Snowflake |
| `.markdownlint.json` | Markdown formatting rules |
| `scripts/validate_*.py` | Custom Oracle migration validators |
| `requirements-precommit.txt` | Pre-commit dependencies |

## Validation Scripts

### 1. Oracle Structure Validator (`validate_oracle_structure.py`)

**Purpose**: Ensures Oracle packages follow the expected directory structure

**Checks**:

- Required directories: `source_code/`, `analysis/`, `views/`

- Required documentation: `README.md`, `conversion_summary.md`

- Oracle package file header comments

- Purpose/description documentation

**Usage**: Automatically runs on Oracle package files

### 2. dbt Naming Validator (`validate_dbt_naming.py`)

**Purpose**: Enforces dbt model naming conventions

**Naming Rules**:

- **Staging**: `stg_[name]` (e.g., `stg_customers.sql`)

- **Intermediate**: `int_[name]` (e.g., `int_customer_orders.sql`)

- **Marts**: `[name]` (e.g., `customer_report.sql`)

- **Oracle Packages**: `oracle_pkg_[name]` (e.g., `oracle_pkg_finance.sql`)

**Additional Checks**:

- Lowercase names only

- No spaces or double underscores

- No reserved SQL keywords

- Proper {{ ref() }}/{{ source() }} usage

### 3. Oracle Macro Coverage (`check_oracle_macro_coverage.py`)

**Purpose**: Ensures Oracle functions have corresponding dbt macros

**Tracked Functions**:

- `NVL`, `NVL2`, `DECODE`

- `TO_DATE`, `TO_CHAR`, `TO_NUMBER`

- `SUBSTR`, `INSTR`, `LENGTH`

- `TRUNC`, `ROWNUM`, `SYSDATE`

- And many more...

**Output**: Suggests macro creation for missing Oracle functions

## Hook Categories

### ✅ **Always Runs**

- General formatting (whitespace, line endings)

- YAML/JSON validation

- Python formatting and linting

- SQL linting (SQLFluff)

### 🎯 **Context-Specific**

- dbt validations (only on dbt model files)

- Oracle structure checks (only on Oracle package files)

- Markdown linting (only on .md files)

### 🚀 **Build Validation**

- dbt compilation check

- Dependency installation

- Model test execution

## Customization

### Adding New Hooks

Edit `.pre-commit-config.yaml`:

```yaml

- repo: <https://github.com/example/new-hook>

  rev: v1.0.0
  hooks:
    - id: new-hook-id

      description: Description of new hook
      files: \.(ext)$

```bash

### Modifying SQL Rules

Edit `.sqlfluff` to adjust SQL linting rules:

```ini

[sqlfluff:rules:L001]

# Configure specific rule

some_setting = value

```bash

### Custom Validation Scripts

Create new scripts in `scripts/` directory and reference them in the `local` repo section of `.pre-commit-config.yaml`.

## Troubleshooting

### Common Issues

### 1. First Run is Slow

- Pre-commit downloads dependencies on first run

- Subsequent runs are much faster

### 2. SQLFluff Template Errors

- Ensure `dbt_project/profiles.yml` is configured

- Check that dbt dependencies are installed

### 3. Hook Failures

- Many failures auto-fix issues - check `git status`

- Read the error output carefully

- Use `git commit --no-verify` only as last resort

### 4. Python Environment Issues

- Ensure Python 3.8+ is installed

- Consider using virtual environment

- Install requirements: `pip install -r requirements-precommit.txt`

### Useful Commands

```bash

# Update all hook versions

pre-commit autoupdate

# Run specific hook type

pre-commit run --hook-stage manual

# Debug hook execution

pre-commit run --verbose sqlfluff-lint

# Clean pre-commit cache

pre-commit clean

# Reinstall hooks

pre-commit uninstall && pre-commit install

```bash

## Integration with CI/CD

The pre-commit configuration can be integrated with GitHub Actions:

```yaml

# .github/workflows/pre-commit.yml

name: Pre-commit
on: [push, pull_request]
jobs:
  pre-commit:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4

    - uses: actions/setup-python@v4

      with:
        python-version: '3.11'
    - uses: pre-commit/action@v3.0.0

```bash

## Benefits

### 🚀 **Developer Experience**

- Immediate feedback on code quality

- Automatic formatting saves time

- Consistent code style across team

- Prevents common mistakes

### 🏛️ **Oracle Migration Quality**

- Ensures proper documentation

- Validates conversion completeness

- Maintains naming consistency

- Tracks macro coverage

### 📊 **Project Maintenance**

- Reduces code review time

- Prevents technical debt

- Enforces best practices

- Improves code reliability

## Future Enhancements

Potential additions to the pre-commit setup:

1. **Security Scanning**: Add hooks for secret detection

2. **Performance Checks**: SQL performance analysis

3. **Documentation Generation**: Auto-update model docs

4. **Test Coverage**: Enforce minimum test coverage

5. **Schema Validation**: Validate dbt schema changes

---

For questions or issues with pre-commit hooks, refer to:

- [Pre-commit Documentation](https://pre-commit.com/)

- [SQLFluff Documentation](https://docs.sqlfluff.com/)

- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
