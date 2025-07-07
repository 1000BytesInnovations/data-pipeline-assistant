
{{ config(materialized='view') }}

/**
 * This model represents the staging table for SSP_RR_CALENDAR.
 * It filters for the 'WSPD_MONTHLY' process.
 */

select
    calendar_year,
    calendar_month,
    active_flg
from LND_MANUAL_ENTRY.SSP_RR_CALENDAR
where process_name = 'WSPD_MONTHLY'
