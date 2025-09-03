{{
    config(
        materialized='table'
    )
}}

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
from {{ ref('ssp_demand_header') }} src
where (1=1)
