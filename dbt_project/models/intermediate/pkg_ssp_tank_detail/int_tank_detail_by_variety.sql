{{
  config(
    materialized='table',
    tags=['intermediate', 'pkg_ssp_tank_detail'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'oracle_step': 'STG_EDW.SSP_TANK_DETAIL_BY_VRTY_04',
      'layer': 'intermediate',
      'business_domain': 'tank_detail'
    }
  )
}}

/*
  Intermediate model for by variety layer

  This model corresponds to the Oracle step that creates STG_EDW.SSP_TANK_DETAIL_BY_VRTY_04
  It groups and aggregates data by variety context - the final intermediate step.

  Oracle Package: PKG_SSP_TANK_DETAIL
  Oracle Step: 13-15 (By Variety Layer)
*/

with
    by_application as (
        select
            *
        from {{ ref('int_tank_detail_by_application') }}
    ),

    by_variety as (
        select
        -- Grouping dimensions from application layer
            calendar_year,
            application_type,
            volume_category,

            -- Variety context (simulated - would come from actual Oracle logic)
            'dbt_pkg_ssp_tank_detail' as create_by,

            'int_tank_detail_by_variety' as create_pgm,

            -- Aggregated metrics from application layer
            'dbt_pkg_ssp_tank_detail' as update_by,
            'int_tank_detail_by_variety' as update_pgm,
            case
                when application_type = 'WINTER_APP' then 'VARIETY_A'
                when application_type = 'SUMMER_APP' then 'VARIETY_B'
            end as variety_type,
            case
                when volume_category = 'HIGH_VOLUME' then 'PREMIUM'
                when volume_category = 'MEDIUM_VOLUME' then 'STANDARD'
                else 'BASIC'
            end as variety_grade,

            -- Variety-specific calculations
            sum(record_count) as total_records,
            sum(total_quarter_blend_key) as total_blend_key,

            -- Final processing flags
            min(min_part_val_date) as earliest_date,

            -- Standard audit columns
            max(max_part_val_date) as latest_date,
            count(*) as variety_count,
            avg(avg_year_month_key) as avg_year_month_key,
            case
                when sum(record_count) > 10 then 'READY_FOR_PROCESSING'
                else 'INSUFFICIENT_DATA'
            end as processing_status,
            current_timestamp() as create_dt,
            current_timestamp() as update_dt,

            -- Metadata
            current_timestamp() as _dbt_loaded_at

        from by_application
        group by
            calendar_year,
            application_type,
            volume_category,
            case
                when application_type = 'WINTER_APP' then 'VARIETY_A'
                when application_type = 'SUMMER_APP' then 'VARIETY_B'
            end,
            case
                when volume_category = 'HIGH_VOLUME' then 'PREMIUM'
                when volume_category = 'MEDIUM_VOLUME' then 'STANDARD'
                else 'BASIC'
            end
    )

select
    *
from by_variety
