{% macro update_interface_run_detail_bima_imp() %}
    UPDATE CBI_METADATA.A_INTERFACE_RUN
    SET LAST_RUN_DATE = SYSDATE()
    WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_DETAIL_BIMA_IMP'
{% endmacro %}
