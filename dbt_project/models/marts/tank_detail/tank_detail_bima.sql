{{ config(
    materialized='incremental',
    unique_key='bima_tank_detail_key',
    incremental_strategy='merge',
    tags=['marts', 'tank_detail', 'bima'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'oracle_step': 'LND_MANUAL_ENTRY.SSP_TANK_DETAIL_BIMA',
      'layer': 'marts',
      'business_domain': 'tank_detail'
    }
  ) }}

/*
  Tank Detail BIMA Mart

  This mart corresponds to the Oracle step that creates LND_MANUAL_ENTRY.SSP_TANK_DETAIL_BIMA
  It provides BIMA-specific transformations and calculations based on the consolidated tank detail data.

  Oracle Package: PKG_SSP_TANK_DETAIL
  Oracle Steps: 19-21 (BIMA Processing)
*/

with

    consolidated_tank_detail as (
        select
            *
        from {{ ref('tank_detail_consolidated') }}
    ),

    bima_transformations as (
        select
            -- Core identifiers
            ctd.tank_detail_key,
            ctd.calendar_year,
            ctd.application_type,
            ctd.variety_type,
            ctd.variety_grade,

            -- BIMA-specific transformations
            ctd.earliest_date,

            -- BIMA calculations
            ctd.latest_date,
            ctd.date_range_days,

            -- BIMA volume classifications
            ctd.total_records,

            -- BIMA risk assessment
            ctd.variety_count,

            -- BIMA compliance flags
            ctd.total_blend_key,

            -- Date and time dimensions
            'BIMA_CONVERSION' as bima_process_type,
            case
                when ctd.seasonal_classification = 'WINTER_SEASON' then 'BIMA_WINTER'
                when ctd.seasonal_classification = 'SUMMER_SEASON' then 'BIMA_SUMMER'
            end as bima_season_type,
            ctd.adjusted_blend_value * 0.85 as bima_adjusted_value,

            -- Original metrics for reference
            ctd.quality_score * 0.9 as bima_quality_score,
            case
                when ctd.total_records > 25 then 'BIMA_HIGH_VOLUME'
                when ctd.total_records > 15 then 'BIMA_MEDIUM_VOLUME'
                when ctd.total_records > 5 then 'BIMA_LOW_VOLUME'
                else 'BIMA_MINIMAL_VOLUME'
            end as bima_volume_category,
            case
                when ctd.performance_indicator = 'HIGH_PERFORMANCE' and ctd.quality_score > 90 then 'LOW_RISK'
                when ctd.performance_indicator = 'MEDIUM_PERFORMANCE' and ctd.quality_score > 70 then 'MEDIUM_RISK'
                else 'HIGH_RISK'
            end as bima_risk_category,

            -- BIMA-specific metrics
            case
                when ctd.quality_score >= 80 and ctd.total_records >= 10 then 'COMPLIANT'
                when ctd.quality_score >= 60 and ctd.total_records >= 5 then 'PARTIAL_COMPLIANT'
                else 'NON_COMPLIANT'
            end as bima_compliance_status,
            ctd.total_blend_key * 1.1 as bima_enhanced_blend_key,

            -- Processing metadata
            ctd.variety_count * 2 as bima_variety_multiplier,
            current_timestamp() as bima_processed_at,

            -- Generate BIMA-specific identifier
            md5(
                coalesce(ctd.tank_detail_key, '')
                || coalesce(ctd.calendar_year::string, '')
                || coalesce(ctd.application_type, '')
                || coalesce(ctd.variety_type, '')
            ) as bima_tank_detail_key

        from consolidated_tank_detail as ctd
        where
            -- Only process records that meet BIMA criteria
            ctd.quality_score >= 50
            and ctd.total_records > 0
            and ctd.performance_indicator in ('HIGH_PERFORMANCE', 'MEDIUM_PERFORMANCE')
            {% if is_incremental() %}
                -- For incremental runs, only process new/changed data
                and ctd.mart_created_at > (
                    select coalesce(max(existing_data.bima_processed_at), '1900-01-01'::timestamp)
                    from {{ this }} as existing_data
                )
            {% endif %}
    )

select
    *
from bima_transformations
