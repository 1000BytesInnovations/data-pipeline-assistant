# Oracle Source Code

This directory contains the original Oracle package source files that are being converted to dbt models.

## Structure

```bash

source_code/
├── PKG_SSP_TANK_DETAIL/
│   ├── package_body.sql        # Original Oracle package body
│   ├── package_spec.sql        # Original Oracle package specification
│   └── dependencies.md         # Package dependencies and objects used
└── [OTHER_PACKAGES]/

```bash

## Purpose

This directory serves as the authoritative source for:

- Original Oracle package code for reference during conversion

- Dependency analysis and impact assessment

- Version control of source packages

- Validation and testing against original logic

## File Naming Convention

- `package_body.sql` - The main package body containing procedures and functions

- `package_spec.sql` - Package specification with public interface definitions

- `dependencies.md` - Documentation of all database objects referenced by the package

## Usage

These files are used by:

1. **Analysis Phase**: Understanding the original business logic and data flow

2. **Conversion Phase**: Ensuring accurate translation to dbt models

3. **Testing Phase**: Comparing outputs between Oracle and dbt implementations

4. **Documentation Phase**: Creating comprehensive conversion documentation

## Maintenance

- Source files should be read-only once placed here

- Any changes to Oracle source should be documented in the analysis files

- Version information should be included in the dependency documentation

For PKG_SSP_TANK_DETAIL, the original Oracle source has been analyzed and documented in the `analysis/` directory.
