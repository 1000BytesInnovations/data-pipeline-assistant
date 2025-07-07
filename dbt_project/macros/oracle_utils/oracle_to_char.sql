{% macro oracle_to_char(value, format_string=None) %}
    {% if format_string %}
    to_char({{ value }}, '{{ format_string }}')
  {% else %}
    to_char({{ value }})
  {% endif %}
{% endmacro %}
