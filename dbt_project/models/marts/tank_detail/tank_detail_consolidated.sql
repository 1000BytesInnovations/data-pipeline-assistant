{{ config(
    materialized='incremental',
    unique_key='tank_detail_key',
    incremental_strategy='merge',
    tags=['marts', 'tank_detail'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'layer': 'marts',
      'business_domain': 'tank_detail'
    }
  ) }}

/*
  Tank Detail Consolidated Mart

  This mart provides the final, business-ready view of tank detail data,
  combining the processed intermediate layers into a consolidated output
  suitable for reporting and analytics.

  Based on Oracle Package: PKG_SSP_TANK_DETAIL
  Final Oracle Target: LND_MANUAL_ENTRY.SSP_TANK_DETAIL
*/

with

    final_variety_data as (
        select
            *
        from {{ ref('int_tank_detail_by_variety') }}
        where processing_status = 'READY_FOR_PROCESSING'
    ),

    blend_expression_data as (
        select
            *
        from {{ ref('int_tank_detail_blend_expression') }}
    ),

    consolidated_tank_detail as (
        select
            -- Primary dimensions
            fvd.calendar_year,
            fvd.application_type,
            fvd.variety_type,
            fvd.variety_grade,
            fvd.volume_category,

            -- Metrics from variety layer
            fvd.total_records,
            fvd.variety_count,
            fvd.total_blend_key,
            fvd.avg_year_month_key,

            -- Enhanced metrics from blend expression
            bed.day_of_year,
            bed.week_of_year,
            bed.blend_expression_hash,

            -- Date dimensions
            fvd.earliest_date,
            fvd.latest_date,
            'tank_detail_consolidated' as mart_source,

            -- Business calculations
            fvd._dbt_loaded_at as source_loaded_at,

            -- Performance indicators
            datediff('day', fvd.earliest_date, fvd.latest_date) as date_range_days,

            -- Seasonal adjustments
            case
                when fvd.variety_grade = 'PREMIUM' then fvd.total_blend_key * 1.5
                when fvd.variety_grade = 'STANDARD' then fvd.total_blend_key * 1.2
                else fvd.total_blend_key
            end as adjusted_blend_value,

            -- Quality scores
            case
                when fvd.total_records > 20 then 'HIGH_PERFORMANCE'
                when fvd.total_records > 10 then 'MEDIUM_PERFORMANCE'
                else 'LOW_PERFORMANCE'
            end as performance_indicator,

            -- Audit and metadata
            case
                when fvd.application_type = 'WINTER_APP' then 'WINTER_SEASON'
                when fvd.application_type = 'SUMMER_APP' then 'SUMMER_SEASON'
            end as seasonal_classification,
            case
                when fvd.variety_grade = 'PREMIUM' and fvd.total_records > 15 then 95
                when fvd.variety_grade = 'STANDARD' and fvd.total_records > 10 then 80
                when fvd.variety_grade = 'BASIC' and fvd.total_records > 5 then 65
                else 50
            end as quality_score,
            current_timestamp() as mart_created_at,

            -- Row identifier
            md5(
                coalesce(fvd.calendar_year::string, '')
                || coalesce(fvd.application_type, '')
                || coalesce(fvd.variety_type, '')
                || coalesce(fvd.variety_grade, '')
            ) as tank_detail_key

        from final_variety_data as fvd
            left join blend_expression_data as bed
                on
                    fvd.calendar_year = bed.calendar_year
                    and fvd.avg_year_month_key = bed.year_month_key
        {% if is_incremental() %}
            where
                -- For incremental runs, only process new/changed data
                fvd._dbt_loaded_at > (
                    select coalesce(max(fvd.source_loaded_at), '1900-01-01'::timestamp)
                    from {{ this }}
                )
        {% endif %}
    )

select
    *
from consolidated_tank_detail
