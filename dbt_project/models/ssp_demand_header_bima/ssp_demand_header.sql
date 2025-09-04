{{
    config(
        materialized='incremental',
        unique_key=['DEMAND_SET', 'DEMAND_SET_NAME'],
        pre_hook='{{ delete_ssp_demand_header() }}',
        post_hook='{{ update_interface_run_ssp_demand_header() }}'
    )
}}

WITH last_run_date_cte AS (
    SELECT MAX(LAST_RUN_DATE) AS max_last_run_date
    FROM CBI_METADATA.A_INTERFACE_RUN
    WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_HEADER_BIMA_IMP'
),
audit_count_cte AS (
    SELECT COUNT(*) AS audit_row_count
    FROM CBI_AUDITS.LND_EXT_FILES_SSP_DEMAND_DETAIL_VW
),
src_data AS (
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
    CROSS JOIN last_run_date_cte lr
    CROSS JOIN audit_count_cte ac
    WHERE (1=1)
      AND SRC.CREATE_DT > lr.max_last_run_date
      AND ac.audit_row_count <= 1
),
existing_data AS (
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
final_insert_rows AS (
    SELECT * FROM src_data
    EXCEPT
    SELECT * FROM existing_data
)
SELECT * FROM final_insert_rows
