{{
  config(
    materialized='table',
    tags=['intermediate', 'pkg_ssp_tank_detail'],
    meta={
      'oracle_source_package': 'PKG_SSP_TANK_DETAIL',
      'oracle_step': 'STG_EDW.SSP_TANK_DETAIL_BLND_EXP_02',
      'layer': 'intermediate',
      'business_domain': 'tank_detail'
    }
  )
}}

/*
  Intermediate model for blend expression layer

  This model corresponds to the Oracle step that creates STG_EDW.SSP_TANK_DETAIL_BLND_EXP_02
  It applies blend and expression logic to the validated source data.

  Oracle Package: PKG_SSP_TANK_DETAIL
  Oracle Step: 7-9 (Blend Expression Layer)
*/

with
    source_validation as (
        select
            *
        from {{ ref('int_tank_detail_source_validation') }}
        where validation_status = 'VALID'
    ),

    blend_expressions as (
        select
        -- Inherited fields from source validation
            calendar_year,
            calendar_month,
            quarter,
            season,
            part_val_date,
            part_val_string,

            -- Blend calculation fields (simulated business logic)
            -- These would be replaced with actual business rules from Oracle views
            'dbt_pkg_ssp_tank_detail' as create_by,

            'int_tank_detail_blend_expression' as create_pgm,

            -- Expression calculations
            'dbt_pkg_ssp_tank_detail' as update_by,
            'int_tank_detail_blend_expression' as update_pgm,

            -- Blend expression result (placeholder for actual Oracle logic)
            calendar_year * 100 + calendar_month as year_month_key,

            -- Standard audit columns
            case
                when quarter = 'Q1' then calendar_year * 1000 + 100
                when quarter = 'Q2' then calendar_year * 1000 + 200
                when quarter = 'Q3' then calendar_year * 1000 + 300
                when quarter = 'Q4' then calendar_year * 1000 + 400
            end as quarter_blend_key,
            extract(dayofyear from part_val_date) as day_of_year,
            extract(week from part_val_date) as week_of_year,
            hash(calendar_year, calendar_month, quarter) as blend_expression_hash,
            current_timestamp() as create_dt,
            current_timestamp() as update_dt,

            -- Metadata
            current_timestamp() as _dbt_loaded_at

        from source_validation
    )

select
    *
from blend_expressions
