{{
    config(
        materialized='table'
    )
}}

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
    src.ACTIVE_FLG,
    src.DATA_SRC,
    src.CREATE_DT,
    src.CREATE_BY,
    src.CREATE_PGM,
    src.UPDATE_DT,
    src.UPDATE_BY,
    src.UPDATE_PGM
from {{ ref('ssp_demand_detail') }} src
where (1=1)
