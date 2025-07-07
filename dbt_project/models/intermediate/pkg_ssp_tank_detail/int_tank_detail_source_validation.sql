{{
  config(
    materialized='table',
    tags=['intermediate', 'pkg_ssp_tank_detail'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'oracle_step': 'STG_EDW.SSP_TANK_DETAIL_SRCVALID_01',
      'layer': 'intermediate',
      'business_domain': 'tank_detail'
    }
  )
}}

/*
  Intermediate model for source validation layer

  This model corresponds to the Oracle step that creates STG_EDW.SSP_TANK_DETAIL_SRCVALID_01
  It performs source data validation and initial transformations.

  Oracle Package: PKG_SSP_TANK_DETAIL
  Oracle Step: 4-6 (Source Validation Layer)
*/

with
    calendar_ref as (
        select
            *
        from {{ ref('stg_ssp_rr_calendar') }}
        where active_flg = 'Y'
    ),

    source_validation as (
        select
        -- Calendar reference fields
            calendar_year,
            calendar_month,
            part_val_date,
            part_val_string,

            -- Add derived fields for tank detail processing
            'dbt_pkg_ssp_tank_detail' as create_by,

            'int_tank_detail_source_validation' as create_pgm,

            -- Validation flags
            'dbt_pkg_ssp_tank_detail' as update_by,

            -- Standard audit columns
            'int_tank_detail_source_validation' as update_pgm,
            case
                when calendar_month between 1 and 3 then 'Q1'
                when calendar_month between 4 and 6 then 'Q2'
                when calendar_month between 7 and 9 then 'Q3'
                when calendar_month between 10 and 12 then 'Q4'
            end as quarter,
            case
                when calendar_month between 4 and 9 then 'Summer'
                else 'Winter'
            end as season,
            case when part_val_date is not null then 'VALID' else 'INVALID' end as validation_status,
            current_timestamp() as create_dt,
            current_timestamp() as update_dt,

            -- Metadata
            current_timestamp() as _dbt_loaded_at

        from calendar_ref
    )

select
    *
from source_validation
