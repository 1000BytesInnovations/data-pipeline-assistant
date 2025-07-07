# Oracle Views

This directory contains Oracle view definitions that are referenced by the packages being converted.

## Structure

```bash

views/
├── PKG_SSP_TANK_DETAIL/
│   ├── view_definitions.sql    # Views used by PKG_SSP_TANK_DETAIL
│   └── view_dependencies.md    # Documentation of view relationships
└── [OTHER_PACKAGES]/

```bash

## Purpose

Oracle packages often reference views that need to be:

- Converted to dbt models or sources

- Documented for dependency analysis

- Mapped to Snowflake equivalents

- Included in the overall data lineage

## View Categories

### Data Views

- Views that provide data transformations

- Often converted to dbt intermediate models

- May include complex business logic

### Lookup Views

- Reference data and lookup tables

- Typically converted to dbt seed files or sources

- Usually small, slowly-changing datasets

### Security Views

- Views that implement row-level security

- May need special handling in Snowflake

- Should be documented for governance requirements

## Conversion Guidelines

1. **Simple Views**: Convert to dbt models in the appropriate layer

2. **Complex Views**: Decompose into multiple intermediate models

3. **Materialized Views**: Convert to dbt tables with appropriate refresh strategies

4. **Security Views**: Implement using Snowflake's row access policies

## Documentation Requirements

For each view, document:

- Original Oracle DDL

- Business purpose and usage

- Dependencies on tables and other views

- Proposed dbt model mapping

- Any Snowflake-specific considerations

Currently, PKG_SSP_TANK_DETAIL does not reference external views, but this directory is maintained for future packages that may have view dependencies.
