{% macro delete_ssp_demand_detail_by_set_name() %}
{% set last_run_date_query %}
    SELECT LAST_RUN_DATE FROM CBI_METADATA.A_INTERFACE_RUN WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_DETAIL_BIMA_IMP'
{% endset %}
{% set last_run_date_result = run_query(last_run_date_query) %}
{% set last_run_date = last_run_date_result.columns[0].values()[0] %}

DELETE FROM LND_MANUAL_ENTRY.SSP_DEMAND_DETAIL
WHERE DEMAND_SET_NAME IN (
    SELECT DISTINCT DEMAND_SET_NAME
    FROM LND_EXT_FILES.SSP_DEMAND_DETAIL
    WHERE CREATE_DT > '{{ last_run_date }}'
)
{% endmacro %}
