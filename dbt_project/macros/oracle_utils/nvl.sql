{#
  Macro to replicate Oracle's NVL function behavior in Snowflake
  Usage: {{ nvl('column_name', 'default_value') }}
#}

{% macro nvl(column, default_value) %}
  coalesce({{ column }}, {{ default_value }})
{% endmacro %}
