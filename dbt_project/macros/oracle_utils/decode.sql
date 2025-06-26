{#
  Macro to replicate Oracle's DECODE function behavior in Snowflake
  Usage: {{ decode('column_name', 'value1', 'result1', 'value2', 'result2', 'default') }}
#}

{% macro decode(column, *args) %}
  case {{ column }}
    {% for i in range(0, args|length - 1, 2) %}
      when {{ args[i] }} then {{ args[i + 1] }}
    {% endfor %}
    {% if args|length % 2 == 1 %}
      else {{ args[-1] }}
    {% endif %}
  end
{% endmacro %}
