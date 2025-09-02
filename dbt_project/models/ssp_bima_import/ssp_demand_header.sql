{{ config(
    materialized='incremental',
    unique_key=['DEMAND_SET', 'DEMAND_SET_NAME'],
    pre_hook="{{ delete_ssp_demand_header_by_set_name() }}",
    post_hook="{{ update_a_interface_run_header() }}"
) }}

WITH last_run_date_cte AS (
    SELECT
        MAX(LAST_RUN_DATE) AS LAST_RUN_DATE
    FROM CBI_METADATA.A_INTERFACE_RUN
    WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_HEADER_BIMA_IMP'
),
source_data_cte AS (
    SELECT DISTINCT
        SRC.DEMAND_SET,
        SRC.DEMAND_SET_NAME,
        SRC.DEMAND_TYPE_CD,
        'Y' AS ACTIVE_FLG, -- Hardcoded from INSERT statement values
        SRC.DATA_SRC,
        SRC.CREATE_DT,
        SRC.CREATE_BY,
        SRC.CREATE_PGM,
        SRC.UPDATE_DT,
        SRC.UPDATE_BY,
        SRC.UPDATE_PGM
    FROM LND_EXT_FILES.SSP_DEMAND_DETAIL SRC
    CROSS JOIN last_run_date_cte LR
    WHERE
        SRC.CREATE_DT > LR.LAST_RUN_DATE
        AND (SELECT COUNT(*) FROM CBI_AUDITS.LND_EXT_FILES_SSP_DEMAND_DETAIL_VW) <= 1
),
final_select AS (
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
    FROM source_data_cte

    EXCEPT

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
)
SELECT * FROM final_select
