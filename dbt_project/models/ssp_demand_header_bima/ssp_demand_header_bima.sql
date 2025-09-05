{{
    config(
        materialized='table',
        post_hook=['{{ update_interface_run_header_bima_imp() }}']
    )
}}

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
FROM {{ ref('ssp_demand_header') }}
WHERE
    (1=1)
