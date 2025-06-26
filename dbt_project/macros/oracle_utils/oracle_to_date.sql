{#
  Macro to handle Oracle date formatting in Snowflake
  Usage: {{ oracle_to_date('date_string', 'format') }}
#}

{% macro oracle_to_date(date_string, format='YYYY-MM-DD') %}
  {% set snowflake_format = format.replace('YYYY', 'YYYY').replace('MM', 'MM').replace('DD', 'DD') %}
  to_date({{ date_string }}, '{{ snowflake_format }}')
{% endmacro %}
