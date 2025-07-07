
{{ config(
    materialized='incremental',
    unique_key='tank_detail_id',
    incremental_strategy='delete+insert',
    pre_hook=[
        "DELETE FROM {{ this }} WHERE to_date(month_partition, 'YYYY-MM-DD') IN (SELECT to_date(part_val, 'YYYY-MM-DD') FROM {{ ref('stg_ssp_rr_calendar') }} WHERE active_flg = 'Y')"
    ]
) }}

/**
 * This model represents the final SSP_TANK_DETAIL table.
 * It is incrementally loaded based on the month specified in the SSP_RR_CALENDAR table.
 * The model will only run if the ACTIVE_FLG in the calendar is 'Y' for the given process.
 */

WITH source_data AS (
    -- This is a placeholder for the actual source of the tank detail data.
    -- The source table and column names should be updated based on the actual ODI mapping.
    SELECT 
        d.tank_detail_id,
        d.tank_name,
        d.product,
        d.capacity,
        d.reading_date,
        c.part_val as month_partition
    FROM LND_MANUAL_ENTRY.SSP_TANK_DETAIL_SRC d
    CROSS JOIN (
        SELECT part_val, active_flg 
        FROM {{ ref('stg_ssp_rr_calendar') }}
    ) c
    WHERE c.active_flg = 'Y'
    AND to_date(d.reading_date, 'YYYY-MM-DD') >= to_date(c.part_val, 'YYYY-MM-DD')
    AND to_date(d.reading_date, 'YYYY-MM-DD') < dateadd(month, 1, to_date(c.part_val, 'YYYY-MM-DD'))
)

SELECT 
    tank_detail_id,
    tank_name,
    product,
    capacity,
    reading_date,
    month_partition
FROM source_data

