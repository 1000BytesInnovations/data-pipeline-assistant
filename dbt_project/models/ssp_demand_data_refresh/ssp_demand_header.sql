{{
    config(
        materialized='incremental',
        unique_key=[
            'DEMAND_SET',
            'DEMAND_SET_NAME'
        ],
        pre_hook="{{ delete_ssp_demand_header() }}",
        post_hook="{{ update_a_interface_run_header() }}"
    )
}}

with last_run_date_header_cte as (
    select max(LAST_RUN_DATE) as max_last_run_date
    from CBI_METADATA.A_INTERFACE_RUN
    where INTERFACE_NAME = 'INT_SSP_DEMAND_HEADER_BIMA_IMP'
),
source_raw as (
    select distinct
        DEMAND_SET,
        DEMAND_SET_NAME,
        DEMAND_TYPE_CD,
        'Y' as ACTIVE_FLG,
        DATA_SRC,
        CREATE_DT,
        CREATE_BY,
        CREATE_PGM,
        UPDATE_DT,
        UPDATE_BY,
        UPDATE_PGM
    from LND_EXT_FILES.SSP_DEMAND_DETAIL
),
filtered_source as (
    select
        src.DEMAND_SET,
        src.DEMAND_SET_NAME,
        src.DEMAND_TYPE_CD,
        src.ACTIVE_FLG,
        src.DATA_SRC,
        src.CREATE_DT,
        src.CREATE_BY,
        src.CREATE_PGM,
        src.UPDATE_DT,
        src.UPDATE_BY,
        src.UPDATE_PGM
    from source_raw src
    join last_run_date_header_cte lr ON src.CREATE_DT > lr.max_last_run_date
    where (select count(*) from CBI_AUDITS.LND_EXT_FILES_SSP_DEMAND_DETAIL_VW) <= 1
)
select * from filtered_source
except
select
    DEMAND_SET,
    DEMAND_SET_NAME,
    DEMAND_TYPE_CD,
    ACTIVE_FLG,
    DATA_SRC,
    CREATE_DT,
    CREATE_BY,
    CREATE_PGM,
    UPDATE_DT,
    UPDATE_BY,
    UPDATE_PGM
from {{ this }}
