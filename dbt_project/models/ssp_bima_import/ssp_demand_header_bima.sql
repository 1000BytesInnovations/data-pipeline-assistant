{{ config(
    materialized='table'
) }}

SELECT
    SRC.DEMAND_SET,
    SRC.DEMAND_SET_NAME,
    SRC.DEMAND_TYPE_CD,
    SRC.ACTIVE_FLG,
    SRC.DATA_SRC,
    SRC.CREATE_DT,
    SRC.CREATE_BY,
    SRC.CREATE_PGM,
    SRC.UPDATE_DT,
    SRC.UPDATE_BY,
    SRC.UPDATE_PGM
FROM {{ ref('ssp_demand_header') }} SRC
WHERE (1=1)
