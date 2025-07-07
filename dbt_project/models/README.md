
# ODI to dbt Conversion Summary

This document summarizes the conversion of the ODI package `PKG_SSP_TANK_DETAIL` to a dbt project.

## ODI Package Converted

- `PKG_SSP_TANK_DETAIL`

## dbt Models Created

- `staging/stg_ssp_rr_calendar.sql`: A view that reads from `LND_MANUAL_ENTRY.SSP_RR_CALENDAR` and filters for the 'WSPD_MONTHLY' process.
- `marts/ssp_tank_detail.sql`: An incremental model that loads data into the `SSP_TANK_DETAIL` table. 

## Assumptions and Simplifications

- **Source Data:** The exact source for the `SSP_TANK_DETAIL` data was not specified in the provided ODI package. I have assumed a source table named `LND_MANUAL_ENTRY.SSP_TANK_DETAIL_SRC` with placeholder columns. This will need to be updated with the actual source table and columns.
- **Oracle-Specific Features:** The ODI package included steps for managing Oracle indexes and partitions. These have been removed as they are not necessary in Snowflake. Snowflake's architecture handles these aspects automatically.
- **Conditional Execution:** The conditional execution logic from the ODI package has been implemented using a `pre_hook` in the `ssp_tank_detail.sql` model. The model will only run if the `ACTIVE_FLG` in the `stg_ssp_rr_calendar` view is 'Y'.
