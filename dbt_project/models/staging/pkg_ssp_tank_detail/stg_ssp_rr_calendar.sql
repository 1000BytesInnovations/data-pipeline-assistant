{{
  config(
    materialized='view',
    tags=['staging', 'pkg_ssp_tank_detail'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'layer': 'staging',
      'business_domain': 'tank_detail'
    }
  )
}}

/*
  Staging model for SSP_RR_CALENDAR - Calendar reference data

  This model cleans and standardizes the calendar reference data used throughout
  the tank detail processing pipeline.

  Source: LND_MANUAL_ENTRY.SSP_RR_CALENDAR
  Oracle Package: PKG_SSP_TANK_DETAIL
*/

with
    source_data as (
        select
            *
        from {{ source('lnd_manual_entry', 'ssp_rr_calendar') }}
    ),

    cleaned as (
        select
            calendar_year,
            calendar_month,
            active_flg,

            -- Generate partition values as done in Oracle
            create_dt,

            create_by,

            -- Standard audit columns
            create_pgm,
            update_dt,
            update_by,
            update_pgm,
            to_date(
                calendar_year || lpad(calendar_month::varchar, 2, '0') || '01',
                'YYYYMMDD'
            ) as part_val_date,
            to_char(
                to_date(
                    calendar_year || lpad(calendar_month::varchar, 2, '0') || '01',
                    'YYYYMMDD'
                ),
                'YYYY-MM-DD'
            ) as part_val_string,

            -- Metadata
            current_timestamp() as _dbt_loaded_at

        from source_data
    )

select
    *
from cleaned
