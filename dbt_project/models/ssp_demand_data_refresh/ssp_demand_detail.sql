{{
    config(
        materialized='incremental',
        unique_key=[
            'DEMAND_SET',
            'DEMAND_SET_NAME',
            'DEMAND_TYPE_CD',
            'ITEM_02_CD',
            'LOCATION',
            'DEMAND_DT',
            'ADDRESS_CD'
        ],
        merge_exclude_columns=[
            'DATA_SRC',
            'CREATE_DT',
            'CREATE_BY',
            'CREATE_PGM',
            'UPDATE_DT',
            'UPDATE_BY',
            'UPDATE_PGM'
        ],
        pre_hook="{{ delete_ssp_demand_detail() }}",
        post_hook="{{ update_a_interface_run_detail() }}"
    )
}}

with last_run_date_detail_cte as (
    select max(LAST_RUN_DATE) as max_last_run_date
    from CBI_METADATA.A_INTERFACE_RUN
    where INTERFACE_NAME = 'INT_SSP_DEMAND_DETAIL_BIMA_IMP'
),
source_raw as (
    select
        DEMAND_SET,
        DEMAND_SET_NAME,
        DEMAND_TYPE_CD,
        NVL(ITEM_02_CD,'UNK') as ITEM_02_CD,
        NVL(LOCATION,'UNK') as LOCATION,
        BLEND_CD,
        to_number(replace(DEMAND_QTY,',','')) as DEMAND_QTY,
        UOM_CD,
        TO_DATE(DEMAND_DT,'YYYY-MM-DD HH:MI:SS AM') as DEMAND_DT,
        TO_DATE(RECOMMENDED_START_DT,'YYYY-MM-DD HH:MI:SS AM') as RECOMMENDED_START_DT,
        TO_DATE(RECOMMENDED_END_DT,'YYYY-MM-DD HH:MI:SS AM') as RECOMMENDED_END_DT,
        to_number(replace(MONTH,',','')) as MONTH,
        to_number(replace(YEAR,',','')) as YEAR,
        NVL(NEW_ITEM_CD,'UNK') as NEW_ITEM_CD,
        to_number(replace(NVL(ADDRESS_CD,'0'),',','')) as ADDRESS_CD,
        BRAND_CD,
        VARIETAL_CD,
        SUB_BRAND_CD,
        ITEM_SIZE_CD,
        OPCO_DSC,
        ACTIVE_FLG,
        CREATE_DT -- Keep original create_dt for filtering
    from LND_EXT_FILES.SSP_DEMAND_DETAIL
),
filtered_source as (
    select
        src.DEMAND_SET,
        src.DEMAND_SET_NAME,
        src.DEMAND_TYPE_CD,
        src.ITEM_02_CD,
        src.LOCATION,
        src.BLEND_CD,
        src.DEMAND_QTY,
        src.UOM_CD,
        src.DEMAND_DT,
        src.RECOMMENDED_START_DT,
        src.RECOMMENDED_END_DT,
        src.MONTH,
        src.YEAR,
        src.NEW_ITEM_CD,
        src.ADDRESS_CD,
        src.BRAND_CD,
        src.VARIETAL_CD,
        src.SUB_BRAND_CD,
        src.ITEM_SIZE_CD,
        src.OPCO_DSC,
        src.ACTIVE_FLG
    from source_raw src
    join last_run_date_detail_cte lr ON src.CREATE_DT > lr.max_last_run_date
    where (select count(*) from CBI_AUDITS.LND_EXT_FILES_SSP_DEMAND_DETAIL_VW) <= 1
),
source_minus_data as (
    select * from filtered_source
    except
    select
        DEMAND_SET,
        DEMAND_SET_NAME,
        DEMAND_TYPE_CD,
        ITEM_02_CD,
        LOCATION,
        BLEND_CD,
        DEMAND_QTY,
        UOM_CD,
        DEMAND_DT,
        RECOMMENDED_START_DT,
        RECOMMENDED_END_DT,
        MONTH,
        YEAR,
        NEW_ITEM_CD,
        ADDRESS_CD,
        BRAND_CD,
        VARIETAL_CD,
        SUB_BRAND_CD,
        ITEM_SIZE_CD,
        OPCO_DSC,
        ACTIVE_FLG
    from {{ this }}
)
select
    s.DEMAND_SET,
    s.DEMAND_SET_NAME,
    s.DEMAND_TYPE_CD,
    s.ITEM_02_CD,
    s.LOCATION,
    s.BLEND_CD,
    s.DEMAND_QTY,
    s.UOM_CD,
    s.DEMAND_DT,
    s.RECOMMENDED_START_DT,
    s.RECOMMENDED_END_DT,
    s.MONTH,
    s.YEAR,
    s.NEW_ITEM_CD,
    s.ADDRESS_CD,
    s.BRAND_CD,
    s.VARIETAL_CD,
    s.SUB_BRAND_CD,
    s.ITEM_SIZE_CD,
    s.OPCO_DSC,
    s.ACTIVE_FLG,
    'LND_JDA.S_F553460Z_JDA_FCST' as DATA_SRC,
    CURRENT_DATE() as CREATE_DT,
    '{{ target.user }}' as CREATE_BY,
    '{{ this.name }}' as CREATE_PGM,
    CURRENT_DATE() as UPDATE_DT,
    '{{ target.user }}' as UPDATE_BY,
    '{{ this.name }}' as UPDATE_PGM
from source_minus_data s
