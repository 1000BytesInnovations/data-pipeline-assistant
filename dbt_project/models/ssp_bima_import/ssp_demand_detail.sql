{{ config(
    materialized='incremental',
    unique_key=['DEMAND_SET', 'DEMAND_SET_NAME', 'DEMAND_TYPE_CD', 'ITEM_02_CD', 'LOCATION', 'DEMAND_DT', 'ADDRESS_CD'],
    pre_hook="{{ delete_ssp_demand_detail_by_set_name() }}",
    post_hook="{{ update_a_interface_run_detail() }}"
) }}

WITH last_run_date_cte AS (
    SELECT
        MAX(LAST_RUN_DATE) AS LAST_RUN_DATE
    FROM CBI_METADATA.A_INTERFACE_RUN
    WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_DETAIL_BIMA_IMP'
),
source_data_cte AS (
    SELECT
        SRC.DEMAND_SET,
        SRC.DEMAND_SET_NAME,
        SRC.DEMAND_TYPE_CD,
        NVL(SRC.ITEM_02_CD, 'UNK') AS ITEM_02_CD,
        NVL(SRC.LOCATION, 'UNK') AS LOCATION,
        SRC.BLEND_CD,
        TO_NUMBER(REPLACE(SRC.DEMAND_QTY, ',')) AS DEMAND_QTY,
        SRC.UOM_CD,
        TO_DATE(SRC.DEMAND_DT, 'YYYY-MM-DD HH:MI:SS AM') AS DEMAND_DT,
        TO_DATE(SRC.RECOMMENDED_START_DT, 'YYYY-MM-DD HH:MI:SS AM') AS RECOMMENDED_START_DT,
        TO_DATE(SRC.RECOMMENDED_END_DT, 'YYYY-MM-DD HH:MI:SS AM') AS RECOMMENDED_END_DT,
        TO_NUMBER(REPLACE(SRC.MONTH, ',')) AS MONTH,
        TO_NUMBER(REPLACE(SRC.YEAR, ',')) AS YEAR,
        NVL(SRC.NEW_ITEM_CD, 'UNK') AS NEW_ITEM_CD,
        TO_NUMBER(REPLACE(NVL(SRC.ADDRESS_CD, '0'), ',')) AS ADDRESS_CD,
        SRC.BRAND_CD,
        SRC.VARIETAL_CD,
        SRC.SUB_BRAND_CD,
        SRC.ITEM_SIZE_CD,
        SRC.OPCO_DSC,
        SRC.ACTIVE_FLG,
        -- Audit columns and DATA_SRC from MERGE statement's VALUES clause
        'LND_JDA.S_F553460Z_JDA_FCST' AS DATA_SRC,
        SYSDATE() AS CREATE_DT,
        '{{ target.user }}' AS CREATE_BY,
        'INT_SSP_DEMAND_DETAIL_BIMA_IMP' AS CREATE_PGM,
        SYSDATE() AS UPDATE_DT,
        '{{ target.user }}' AS UPDATE_BY,
        'INT_SSP_DEMAND_DETAIL_BIMA_IMP' AS UPDATE_PGM
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
