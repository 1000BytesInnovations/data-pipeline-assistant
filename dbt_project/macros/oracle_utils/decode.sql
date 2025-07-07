{#
  Macro to replicate Oracle's DECODE function behavior in Snowflake
  Usage: {{ decode('column_name', 'value1', 'result1', 'value2', 'result2', 'default') }}
#}

{% macro decode(column, values_and_results) %}
    {%- set pairs = values_and_results.split(',') -%}
    case {{ column }}
    {% for i in range(0, pairs|length - 1, 2) %}
        {% if loop.index <= pairs|length - 1 %}
        when {{ pairs[i]|trim }} then {{ pairs[i + 1]|trim }}
        {% endif %}
    {% endfor %}
{% if pairs|length % 2 == 1 %}
      else {{ pairs[-1]|trim }}
{% endif %}
  end
{% endmacro %}
