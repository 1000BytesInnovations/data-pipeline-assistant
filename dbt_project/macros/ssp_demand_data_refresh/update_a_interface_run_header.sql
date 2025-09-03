{% macro update_a_interface_run_header() %}
    {% set command %}
        UPDATE CBI_METADATA.A_INTERFACE_RUN
        SET LAST_RUN_DATE = CURRENT_DATE()
        WHERE INTERFACE_NAME = 'INT_SSP_DEMAND_HEADER_BIMA_IMP';
    {% endset %}
    {% do run_query(command) %}
{% endmacro %}
