{% macro delete_ssp_demand_detail() %}
    {% set command %}
        with last_run_date_cte as (
            select LAST_RUN_DATE
            from CBI_METADATA.A_INTERFACE_RUN
            where INTERFACE_NAME = 'INT_SSP_DEMAND_DETAIL_BIMA_IMP'
        )
        DELETE FROM LND_MANUAL_ENTRY.SSP_DEMAND_DETAIL
        WHERE DEMAND_SET_NAME IN (
            SELECT DISTINCT DEMAND_SET_NAME
            FROM LND_EXT_FILES.SSP_DEMAND_DETAIL
            WHERE CREATE_DT > (SELECT LAST_RUN_DATE FROM last_run_date_cte)
        );
    {% endset %}
    {% do run_query(command) %}
{% endmacro %}
