{{
  config(
    materialized='table',
    tags=['intermediate', 'pkg_ssp_tank_detail'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'oracle_step': 'STG_EDW.SSP_TANK_DETAIL_BY_APP_03',
      'layer': 'intermediate',
      'business_domain': 'tank_detail'
    }
  )
}}

/*
  Intermediate model for by application layer

  This model corresponds to the Oracle step that creates STG_EDW.SSP_TANK_DETAIL_BY_APP_03
  It groups and aggregates data by application context.

  Oracle Package: PKG_SSP_TANK_DETAIL
  Oracle Step: 10-12 (By Application Layer)
*/

with
    blend_expressions as (
        select
            *
        from {{ ref('int_tank_detail_blend_expression') }}
    ),

    by_application as (
        select
        -- Grouping dimensions
            calendar_year,
            quarter,
            season,

            -- Application context (simulated - would come from actual Oracle logic)
            'dbt_pkg_ssp_tank_detail' as create_by,

            -- Aggregated metrics
            'int_tank_detail_by_application' as create_pgm,
            'dbt_pkg_ssp_tank_detail' as update_by,
            'int_tank_detail_by_application' as update_pgm,
            case
                when quarter in ('Q1', 'Q4') then 'WINTER_APP'
                when quarter in ('Q2', 'Q3') then 'SUMMER_APP'
            end as application_type,
            count(*) as record_count,

            -- Application-specific calculations
            min(calendar_month) as min_month,

            -- Date aggregations
            max(calendar_month) as max_month,
            avg(year_month_key) as avg_year_month_key,

            -- Standard audit columns
            sum(quarter_blend_key) as total_quarter_blend_key,
            case
                when count(*) > 6 then 'HIGH_VOLUME'
                when count(*) > 3 then 'MEDIUM_VOLUME'
                else 'LOW_VOLUME'
            end as volume_category,
            min(part_val_date) as min_part_val_date,
            max(part_val_date) as max_part_val_date,
            current_timestamp() as create_dt,
            current_timestamp() as update_dt,

            -- Metadata
            current_timestamp() as _dbt_loaded_at

        from blend_expressions
        group by
            calendar_year,
            quarter,
            season,
            case
                when quarter in ('Q1', 'Q4') then 'WINTER_APP'
                when quarter in ('Q2', 'Q3') then 'SUMMER_APP'
            end
    )

select
    *
from by_application
