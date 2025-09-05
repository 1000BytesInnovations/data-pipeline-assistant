{{
    config(
        materialized='incremental',
        unique_key=['DEMAND_SET', 'DEMAND_SET_NAME'],
        pre_hook=['{{ delete_ssp_demand_header() }}']
    )
}}

WITH max_last_run_date_cte AS (
    SELECT MAX(LAST_RUN_DATE) AS LAST_RUN_DATE_VALUE
    FROM CBI_METADATA.A_INTERFACE_RUN
    WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_HEADER_BIMA_IMP'
),
count_lnd_ext_files_ssp_demand_detail_vw_cte AS (
    SELECT COUNT(*) AS COUNT_VALUE
    FROM CBI_AUDITS.LND_EXT_FILES_SSP_DEMAND_DETAIL_VW
),
source_processed AS (
    SELECT DISTINCT
        SRC.DEMAND_SET,
        SRC.DEMAND_SET_NAME,
        SRC.DEMAND_TYPE_CD,
        'Y' AS ACTIVE_FLG,
        SRC.DATA_SRC,
        SRC.CREATE_DT,
        SRC.CREATE_BY,
        SRC.CREATE_PGM,
        SRC.UPDATE_DT,
        SRC.UPDATE_BY,
        SRC.UPDATE_PGM
    FROM LND_EXT_FILES.SSP_DEMAND_DETAIL SRC
    JOIN max_last_run_date_cte LRD ON 1=1
    JOIN count_lnd_ext_files_ssp_demand_detail_vw_cte CVC ON 1=1
    WHERE SRC.CREATE_DT > LRD.LAST_RUN_DATE_VALUE
      AND CVC.COUNT_VALUE <= 1
),
target_existing AS (
    SELECT
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
    FROM {{ this }}
),
rows_to_insert AS (
    SELECT * FROM source_processed
    EXCEPT
    SELECT * FROM target_existing
)
SELECT *
FROM rows_to_insert
